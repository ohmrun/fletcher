package eu.ohmrun.fletcher;

enum CommandArgSum<I,E>{
  CommandArgFun1Void(fn:I->Void);
  CommandArgFun1Report(fn:I->Report<E>);
  CommandArgFun1OptionRefuse(fn:I->Option<Refuse<E>>);
  CommandFun1Execute(fn:I->Execute<E>);
}
abstract CommandArg<I,E>(CommandArgSum<I,E>) from CommandArgSum<I,E> to CommandArgSum<I,E>{
  public function new(self) this = self;
  static public function lift<I,E>(self:CommandArgSum<I,E>):CommandArg<I,E> return new CommandArg(self);

  public function prj():CommandArgSum<I,E> return this;
  private var self(get,never):CommandArg<I,E>;
  private function get_self():CommandArg<I,E> return lift(this);

  @:from static public function fromCommandFun1Execute<I,E>(fn:I->Execute<E>):CommandArg<I,E>{
    return lift(CommandFun1Execute(fn));
  }
  @:from static public function fromCommandArgFun1Report<I,E>(fn:I->Report<E>):CommandArg<I,E>{
    return CommandArgFun1Report(fn);
  }
  @:from static public function fromCommandArgFun1OptionRefuse<I,E>(fn:I->Option<Refuse<E>>):CommandArg<I,E>{
    return CommandArgFun1OptionRefuse(fn);
  }
  @:from static public function fromCommandArgFun1Void<I,E>(fn:I->Void):CommandArg<I,E>{
    return CommandArgFun1Void(fn);
  }
  @:to public function toCommand(){
    return switch(this){
      case CommandFun1Execute(x)            : Command.fromFun1Execute(x);
      case CommandArgFun1Void(x)            : Command.fromFun1Void(x);
      case CommandArgFun1Report(x)          : Command.fromFun1Report(x);
      case CommandArgFun1OptionRefuse(x) : Command.fromFun1OptionRefuse(x);
    }
  }
}
typedef CommandDef<I,E>                 = FletcherDef<I,Report<E>,Noise>;

@:using(eu.ohmrun.fletcher.Command.CommandLift)
@:forward abstract Command<I,E>(CommandDef<I,E>) from CommandDef<I,E> to CommandDef<I,E>{
  static public var _(default,never) = CommandLift;
  public function new(self){
    this = self;
  }
  static public function unit<I,E>():Command<I,E>{
    return lift(Fletcher.Sync((i:I)->Report.unit()));
  }
  static public inline function lift<I,E>(self:CommandDef<I,E>):Command<I,E>{
    return new Command(self);
  }
  static public inline function bump<I,E>(self:CommandArg<I,E>):Command<I,E>{
    return self.toCommand();
  }

  static public function fromFun1Void<I,E>(fn:I->Void):Command<I,E>{
    return lift(Fletcher.Sync(__.passthrough(fn).fn().then((_)->Report.unit())));
  }
  static public function fromFun1Report<I,E>(fn:I->Report<E>):Command<I,E>{
    return lift(Fletcher.fromFun1R((i) -> fn(i)));
  }
  static public function fromFun1OptionRefuse<I,E>(fn:I->Option<Refuse<E>>):Command<I,E>{
    return lift(Fletcher.fromFun1R((i) -> Report.fromOption(fn(i))));
  } 
  static public function fromFletcher<I,E>(self:Fletcher<I,Noise,E>):Command<I,E>{
    return lift(
      Fletcher.Anon((p:I,cont:Terminal<Report<E>,Noise>) -> cont.receive(
        self.forward(p).fold_mapp(
          _ -> __.success(__.report()),
          e -> __.success(e.toRefuse().report())
        )
      )
    ));
  }
  static public function fromFun1Execute<I,E>(fn:I->Execute<E>):Command<I,E>{
    return lift(
      Fletcher.Anon(
        (i:I,cont:Terminal<Report<E>,Noise>) -> {
          __.log().debug(_ -> _.pure(i));
          return cont.receive(fn(i).forward(Noise));
        }
      )
    );
  }
  public function toModulate():Modulate<I,I,E>{
    return Modulate.lift(
      Fletcher.Anon((p:Res<I,E>,cont:Waypoint<I,E>) -> p.fold(
        ok -> cont.receive(
          this.forward(ok).fold_mapp(
            report -> report.fold(
              e   -> __.success(__.reject(e)),
              ()  -> __.success(__.accept(ok)) 
            ),
            (e) -> __.failure(e)
          )
        ),
        no -> cont.receive(cont.value(__.reject(no)))
      )
    ));
  }
  public function prj():CommandDef<I,E>{
    return this;
  }
  public inline function toFletcher():Fletcher<I,Report<E>,Noise>{
    return this;
  }
  public function and(that:Command<I,E>):Command<I,E>{
    return lift(
      Fletcher._.split(
        self,
        that.toFletcher()).map((tp) -> tp.fst().concat(tp.snd()))
    );
  }
  public function errata<EE>(fn:Refuse<E>->Refuse<EE>){
    return self.map((report) -> report.errata(fn));
  }
  public function provide(i:I):Execute<E>{
    return Execute.lift(
      Fletcher.Anon((_:Noise,cont:Terminal<Report<E>,Noise>) -> cont.receive(this.forward(i)))
    );
  }
  private var self(get,never):Command<I,E>;
  private function get_self():Command<I,E> return this;

} 
class CommandLift{
  static public function toModulate<I,O,E>(command:CommandDef<I,E>):Modulate<I,I,E>{
    return Modulate.lift(
      Fletcher.Anon((p:Res<I,E>,cont:Waypoint<I,E>) -> p.fold(
        (okI:I) -> cont.receive(command.forward(okI).fold_mapp(
          okII -> okII.fold(
            er -> __.success(__.reject(er)),
            () -> __.success(__.accept(okI))
          ),
          er -> __.failure(er) 
        )),
        er -> cont.receive(cont.value(__.reject(er)))
      )
    ));
  }
  static public function produce<I,O,E>(command:Command<I,E>,prod:Produce<O,E>):Attempt<I,O,E>{
    return Attempt.lift(
      Fletcher.Then(
        command.toFletcher(),
        Fletcher.Anon(
          (ipt:Report<E>,cont:Terminal<Res<O,E>,Noise>) -> {
            __.log().debug(_ -> _.pure(ipt));
            return ipt.fold(
              e   -> cont.receive(cont.value(__.reject(e))),
              ()  -> cont.receive(prod.forward(Noise))
            );
          }
        )
      )
    );
  }
}