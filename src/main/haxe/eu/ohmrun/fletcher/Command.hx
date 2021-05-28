package eu.ohmrun.fletcher;
        
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
  @:from static public function fromFun1Void<I,E>(fn:I->Void):Command<I,E>{
    return lift(Fletcher.Sync(__.passthrough(fn).fn().then((_)->Report.unit())));
  }
  @:from static public function fromFun1Report<I,E>(fn:I->Report<E>):Command<I,E>{
    return lift(Fletcher.fromFun1R((i) -> fn(i)));
  }
  static public function fromFun1Option<I,E>(fn:I->Option<Err<E>>):Command<I,E>{
    return lift(Fletcher.fromFun1R((i) -> Report.fromOption(fn(i))));
  } 
  static public function fromFletcher<I,E>(self:Fletcher<I,Noise,E>):Command<I,E>{
    return lift(
      (p:I,cont:Terminal<Report<E>,Noise>) -> cont.receive(
        self.forward(p).fold_mapp(
          _ -> __.success(__.report()),
          e -> __.success(e.toErr().report())
        )
      )
    );
  }
  @:from static public function fromFun1Execute<I,E>(fn:I->Execute<E>):Command<I,E>{
    return lift(
      Fletcher.Anon(
        (i:I,cont) -> cont.receive(fn(i).forward(Noise))
      )
    );
  }
  public function toCascade():Cascade<I,I,E>{
    return Cascade.lift(
      (p:Res<I,E>,cont:Waypoint<I,E>) -> p.fold(
        ok -> cont.receive(
          this.forward(ok).fold_mapp(
            report -> report.fold(
              e   -> __.success(__.reject(e)),
              ()  -> __.success(__.accept(ok)) 
            ),
            (e) -> __.failure(e)
          )
        ),
        no -> cont.value(__.reject(no)).serve()
      )
    );
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
        that.toFletcher()).map((tp) -> tp.fst().merge(tp.snd()))
    );
  }
  public function errata<EE>(fn:Err<E>->Err<EE>){
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
  static public function toCascade<I,O,E>(command:CommandDef<I,E>):Cascade<I,I,E>{
    return Cascade.lift(
      (p:Res<I,E>,cont:Waypoint<I,E>) -> p.fold(
        (okI:I) -> cont.receive(command.forward(okI).fold_map(
          okII -> okII.fold(
            er -> __.success(__.reject(er)),
            () -> __.success(__.accept(okI))
          ),
          er -> __.failure(er) 
        )),
        er -> cont.value(__.reject(er)).serve()
      )
    );
  }
  static public function produce<I,O,E>(command:Command<I,E>,produce:Produce<O,E>):Attempt<I,O,E>{
    return Attempt.lift(
      Fletcher.Then(
        command.toFletcher(),
        Fletcher.Anon(
          (ipt:Report<E>,cont:Terminal<Res<O,E>,Noise>) -> ipt.fold(
            e   -> cont.value(__.reject(e)).serve(),
            ()  -> cont.receive(produce.forward(Noise))
          )
        )
      )
    );
  }
}