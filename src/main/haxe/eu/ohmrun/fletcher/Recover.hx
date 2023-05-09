package eu.ohmrun.fletcher;
        
typedef RecoverDef<I,E>                 = FletcherDef<Refuse<E>,I,Nada>;

@:forward abstract Recover<I,E>(RecoverDef<I,E>) from RecoverDef<I,E> to RecoverDef<I,E>{
  public inline function new(self) this = self;
  @:noUsing static public inline function lift<I,E>(self:RecoverDef<I,E>) return new Recover(self);

  @:from static public function fromFunErrR<I,E>(fn:Refuse<E>->I):Recover<I,E>{
    return lift(Fletcher.Sync(fn));
  }
  public function toModulate():Modulate<I,I,E> return Modulate.lift(
    Fletcher.Anon((p:Upshot<I,E>,cont:Waypoint<I,E>) -> p.fold(
      ok -> cont.receive(
        cont.value(__.accept(ok))
      ),
      no -> cont.receive(
        this.forward(no).map(__.accept)
      )
    ))
  );
  public function toReform():Reform<I,I,E> return Reform.lift(
    Fletcher.Anon((p:Upshot<I,E>,cont:Terminal<I,Nada>) -> p.fold(
      ok -> cont.receive(cont.value(ok)),
      er -> cont.receive(this.forward(er))
    ))
  );

  public inline function prj():RecoverDef<I,E>{
    return this;
  }
  public inline function toFletcher():Fletcher<Refuse<E>,I,Nada>{
    return Fletcher.lift(this);
  }
} 
class RecoverLift{
  static public function toReform<I,E>(self:Recover<I,E>):Reform<I,I,E>{
    return Reform.lift(Fletcher.Anon((p:Upshot<I,E>,cont:Terminal<I,Nada>) -> {
      return p.fold(
        ok -> cont.value(ok).serve(),
        no -> cont.receive(
          self.forward(no).fold_mapp(
            ok -> __.success(ok),
            _  -> __.failure(_)
          )
        )
      );
    }));
  }
  static public function toModulate<I,E>(self:Recover<I,E>):Modulate<I,I,E>{
    return Modulate.lift(
      Fletcher.Anon((p:Upshot<I,E>,cont:Waypoint<I,E>) -> p.fold(
        ok -> cont.value(__.accept(ok)).serve(),
        no -> cont.receive(self.forward(no).map(__.accept)))
    ));
  }
}