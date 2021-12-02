package eu.ohmrun.fletcher;
        
typedef RecoverDef<I,E>                 = FletcherDef<Error<E>,I,Noise>;

@:forward abstract Recover<I,E>(RecoverDef<I,E>) from RecoverDef<I,E> to RecoverDef<I,E>{
  public inline function new(self) this = self;
  @:noUsing static public inline function lift<I,E>(self:RecoverDef<I,E>) return new Recover(self);

  @:from static public function fromFunErrR<I,E>(fn:Error<E>->I):Recover<I,E>{
    return lift(Fletcher.Sync(fn));
  }
  public function toCascade():Cascade<I,I,E> return Cascade.lift(
    (p:Res<I,E>,cont:Waypoint<I,E>) -> p.fold(
      ok -> cont.value(__.accept(ok)).serve(),
      no -> cont.receive(
        this.forward(no).map(__.accept)
      )
    )
  );
  public function toRectify():Rectify<I,I,E> return Rectify.lift(
    (p:Res<I,E>,cont:Terminal<I,Noise>) -> p.fold(
      ok -> cont.value(ok).serve(),
      er -> cont.receive(this.forward(er))
    )
  );

  public inline function prj():RecoverDef<I,E>{
    return this;
  }
  public inline function toFletcher():Fletcher<Error<E>,I,Noise>{
    return Fletcher.lift(this);
  }
} 
class RecoverLift{
  static public function toRectify<I,E>(self:Recover<I,E>):Rectify<I,I,E>{
    return Rectify.lift((p:Res<I,E>,cont:Terminal<I,Noise>) -> {
      return p.fold(
        ok -> cont.value(ok).serve(),
        no -> cont.receive(
          self.forward(no).fold_mapp(
            ok -> __.success(ok),
            _  -> __.failure(_)
          )
        )
      );
    });
  }
  static public function toCascade<I,E>(self:Recover<I,E>):Cascade<I,I,E>{
    return Cascade.lift(
      (p:Res<I,E>,cont:Waypoint<I,E>) -> p.fold(
        ok -> cont.value(__.accept(ok)).serve(),
        no -> cont.receive(self.forward(no).map(__.accept)))
    );
  }
}