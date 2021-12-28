package eu.ohmrun.fletcher;

typedef ReframeDef<I,O,E>               = ModulateDef<I,Couple<O,I>,E>;

@:using(eu.ohmrun.fletcher.Reframe.ReframeLift)
@:forward abstract Reframe<I,O,E>(ReframeDef<I,O,E>) from ReframeDef<I,O,E> to ReframeDef<I,O,E>{
  static public var _(default,never) = ReframeLift;

  public inline function new(self) this = self;

  @:noUsing static public inline function lift<I,O,E>(wml:ReframeDef<I,O,E>):Reframe<I,O,E> return new Reframe(wml);
  @:noUsing static public inline function pure<I,O,E>(o:O):Reframe<I,O,E>{
    return lift(Fletcher._.map(
      Modulate.unit(),
      (oc:Res<I,E>) -> (oc.map(__.couple.bind(o)):Res<Couple<O,I>,E>)
    ));
  }
  
  private var self(get,never):Reframe<I,O,E>;
  private function get_self():Reframe<I,O,E> return this;


  @:to public function toModulate():Modulate<I,Couple<O,I>,E>{
    return Modulate.lift(this);
  }
  @:to public inline function toFletcher():Fletcher<Res<I,E>,Res<Couple<O,I>,E>,Noise>{
    return Fletcher.lift(this);
  }
  @:from static public function fromModulate<I,O,E>(self:Modulate<I,Couple<O,I>,E>):Reframe<I,O,E>{
    return lift(self);
  }
}

class ReframeLift{
  static private function lift<I,O,E>(wml:ReframeDef<I,O,E>):Reframe<I,O,E> return new Reframe(wml);
  
  static public function modulate<I,Oi,Oii,E>(self:Reframe<I,Oi,E>,that:Modulate<Couple<Oi,I>,Oii,E>):Modulate<I,Oii,E>{
    return Modulate.lift(Fletcher.Then(self,that));
  }
  static public function attempt<I,O,Oi,E>(self:Reframe<I,O,E>,that:Attempt<O,Oi,E>):Reframe<I,Oi,E>{
    var fn = (chk:Res<Couple<Res<Oi,E>,I>,E>) -> (chk.flat_map(
      (tp) -> tp.fst().map(
        (r) -> __.couple(r,tp.snd())
      )
    ):Res<Couple<Oi,I>,E>);
    var arw =  lift(
      Fletcher._.map(self.toModulate().convert(
        Convert.lift(that.toFletcher().first())
      ),fn)
    );
    return arw;
  }
  static public function rearrange<I,O,Oi,E>(self:Reframe<I,O,E>,that:Arrange<Res<O,E>,I,Oi,E>):Reframe<I,Oi,E>{
    return Reframe.lift(
      Fletcher.Anon(
        (ipt:Res<I,E>,cont:Terminal<Res<Couple<Oi,I>,E>,Noise>) -> return cont.receive(self.forward(ipt).flat_fold(
          (res:Res<Couple<O,I>,E>) -> that.forward(
            res.fold(
              (tp:Couple<O,I>)  -> __.accept(__.couple(__.accept(tp.fst()),tp.snd())),
              (err)             -> ipt.fold(i -> __.accept(__.couple(__.reject(err),i)),e -> __.reject(e))
            )
          ).map(res -> res.zip(ipt)),
          err -> cont.error(err)
        ))
      )
    );
  }
  static public function arrange<I,O,Oi,E>(self:Reframe<I,O,E>,that:Arrange<O,I,Oi,E>):Reframe<I,Oi,E>{
    var arw = 
      Fletcher._.map(
        modulate(self,that).broach(),
        (res:Res<Couple<I,Oi>,E>) -> {
            return res.map(tp -> tp.swap());
          }
        );
    return Reframe.lift(arw);
  }
  static public function arrangement<I,Ii,O,Oi,E>(self:Reframe<I,O,E>,that:O->Arrange<Ii,I,Oi,E>):Attempt<Couple<Ii,I>,Oi,E>{
    return Attempt.lift(Fletcher.Anon(
      (ipt:Couple<Ii,I>,cont:Terminal<Res<Oi,E>,Noise>) -> cont.receive(self.forward(__.success(ipt.snd())).flat_fold(
        (tp:Res<Couple<O,I>,E>) -> tp.fold(
          tp  -> that(tp.fst()).forward(__.success(ipt)),
          err -> cont.value(__.reject(err))
        ),
        e -> cont.error(e)
      ))
    ));
  }
  static public function commandeer<I,O,E>(self:Reframe<I,O,E>,fn:O->Command<I,E>):Command<I,E>{
    return Command.lift(
      Fletcher.Anon(
        (ipt:I,cont:Terminal<Report<E>,Noise>) -> cont.receive(self.commandment(fn).then(
          Fletcher.Sync(
            (res:Res<Couple<O,I>,E>) -> res.fold(
              _ -> Report.unit(),
              Report.pure
            )
          )
        ).forward(__.accept(ipt)))
      )
    );
  }
  static public function commandment<I,O,E>(self:Reframe<I,O,E>,fn:O->Command<I,E>):Reframe<I,O,E>{
    return lift(Fletcher.Anon(
      (ipt:Res<I,E>,cont:Terminal<Res<Couple<O,I>,E>,Noise>) -> cont.receive(self.forward(ipt).flat_fold(
        res -> res.fold(
          ok -> {
            var cmd = fn(ok.fst());//TODO HMMM
            return ipt.fold(
              i -> cmd.forward(i).map(
                report -> report.fold(
                  err -> __.reject(err),
                  ()  -> __.accept(__.couple(ok.fst(),i))//TODO also hmm
                )
              ),
              e -> cont.value(__.reject(e))
            );
          },
          no -> cont.value(__.reject(no))
        ),
        (no)  -> cont.error(no)
      )
    )));
  }
  static public function evaluation<I,O,E>(self:Reframe<I,O,E>):Modulate<I,O,E>{
    return Modulate.lift(self.map(o -> o.map(tp -> tp.fst())));
  }

  static public function execution<I,O,E>(self:Reframe<I,O,E>):Modulate<I,I,E>{
    return Modulate.lift(self.map(o -> o.map(tp -> tp.snd())));
  }
  static public function errate<I,O,E,EE>(self:Reframe<I,O,E>,fn:E->EE):Reframe<I,O,EE>{
    return lift(
      Fletcher.Anon(
        (i:Res<I,EE>,cont:Terminal<Res<Couple<O,I>,EE>,Noise>) -> i.fold(
          (i) -> cont.receive(self.map(o -> o.errata((e) -> e.errate(fn))).forward(__.accept(i))),
          (e) -> cont.value(__.reject(e)).serve()
        )
      )
    );
  }
  static public inline function environment<I,O,E>(self:Reframe<I,O,E>,i:I,success:Couple<O,I>->Void,failure:Rejection<E>->Void):Fiber{
    return Modulate._.environment(
      self,
      i,
      success,
      failure
    );
  }
  static public function convert<I,O,Oi,E>(self:Reframe<I,O,E>,fn:Convert<O,Oi>):Reframe<I,Oi,E>{
    return lift(self.modulate(
      fn.first().toModulate()
    ));
  }
}