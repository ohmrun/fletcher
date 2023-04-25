package eu.ohmrun.fletcher;

typedef DiffuseDef<I,O,E> = FletcherDef<Chunk<I,E>,Chunk<O,E>,Noise>;

@:using(eu.ohmrun.fletcher.Diffuse.DiffuseDef)
abstract Diffuse<I,O,E>(DiffuseDef<I,O,E>) from DiffuseDef<I,O,E> to DiffuseDef<I,O,E>{
  static public var _(default,never) = DiffuseLift;
  public inline function new(self) this = self;
  static public inline function lift<I,O,E>(self:DiffuseDef<I,O,E>):Diffuse<I,O,E> return new Diffuse(self);
  static public inline function unit<P,E>():Diffuse<P,P,E>{
    return lift(
      Fletcher.Sync(
        (chk:Chunk<P,E>) -> chk
      )
    );
  }
  
  @:from static public function fromFunIOptionR<I,O,E>(fn:I->Option<O>):Diffuse<I,O,E>{
    return lift(
      Fletcher.Anon(
        (ipt:Chunk<I,E>,cont:Terminal<Chunk<O,E>,Noise>) -> {
          return ipt.fold(
            (o) -> cont.value(fn(o).fold(
              (o) -> Val(o),
              ()  -> Tap
            )).serve(),
            (e) -> cont.value(End(e)).serve(),
            ()  -> cont.value(Tap).serve()
          );
        }
      )
    );
  }
  @:from static public function fromOptionIR<I,O,E>(fn:Option<I>->O):Diffuse<I,O,E>{
    return lift(
      Fletcher.Anon(
        (ipt:Chunk<I,E>,cont:Terminal<Chunk<O,E>,Noise>) -> {
          return ipt.fold(
           (i)  -> cont.value(Val(fn(Some(i)))).serve(),
           (e)  -> cont.value(End(e)).serve(),
           ()   -> cont.value(Val(fn(None))).serve()
          );
        }
      )
    );
  }
  public function prj():DiffuseDef<I,O,E> return this;
  private var self(get,never):Diffuse<I,O,E>;
  private function get_self():Diffuse<I,O,E> return lift(this);

  public inline function toFletcher():Fletcher<Chunk<I,E>,Chunk<O,E>,Noise>{
    return Fletcher.lift(this);
  }
}
class DiffuseLift{
  static private inline function lift<I,O,E>(self:DiffuseDef<I,O,E>):Diffuse<I,O,E> return Diffuse.lift(self);
  static public function attempt<P,Oi,Oii,E>(self:DiffuseDef<P,Oi,E>,that:Attempt<Oi,Oii,E>):Diffuse<P,Oii,E>{
    return lift(self.then(
      Fletcher.Anon(
        (chk:Chunk<Oi,E>,cont:Terminal<Chunk<Oii,E>,Noise>) -> cont.receive(
          chk.fold(
            ok -> that.toFletcher().map(Upshot._.toChunk).forward(ok),
            no -> cont.value(End(no)),
            () -> cont.value(Tap)
          )
        )
      )
    ));
  }
  static public function adjust<P,Oi,Oii,E>(self:DiffuseDef<P,Oi,E>,that:Oi->Upshot<Oii,E>):Diffuse<P,Oii,E>{
    return lift(self.then(
      Fletcher.Anon(
        (chk:Chunk<Oi,E>,cont:Terminal<Chunk<Oii,E>,Noise>) -> cont.receive(
          chk.fold(
            ok -> cont.value(that(ok).toChunk()),
            no -> cont.value(End(no)),
            () -> cont.value(Tap)
          )
        )
      )
    ));
  }
}