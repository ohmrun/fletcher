package eu.ohmrun.fletcher;
        
typedef ResolveDef<I,E> = FletcherDef<Err<E>,Chunk<I,E>,Noise>;

/**
  Chunk.Tap signifies no resolution has been found.
**/
@:using(eu.ohmrun.fletcher.Resolve.ResolveLift)
abstract Resolve<I,E>(ResolveDef<I,E>) from ResolveDef<I,E> to ResolveDef<I,E>{
  public inline function new(self) this = self;
  static public inline function lift<I,E>(self:ResolveDef<I,E>):Resolve<I,E> return new Resolve(self);
  
  @:from static public function fromResolvePropose<I,E>(self:Fletcher<Err<E>,Propose<I,E>,Noise>):Resolve<I,E>{
    return lift(
      self.then(
        (i:Propose<I,E>,cont:Terminal<Chunk<I,E>,Noise>) -> cont.receive(
          i.forward(Noise)
        )
      )
    );
  }
  @:from static public function fromFunErrPropose<I,E>(arw:Err<E>->Propose<I,E>):Resolve<I,E>{
    return lift(
      Fletcher.Then(
        Fletcher.Sync(arw),
        Fletcher.Anon((i:Propose<I,E>,cont:Terminal<Chunk<I,E>,Noise>) -> cont.receive(
          i.forward(Noise) 
        ))
      )
    );
  }
  @:from static public function fromErrChunk<I,E>(fn:Err<E>->Chunk<I,E>):Resolve<I,E>{
    return lift(Fletcher.Sync(fn));
  }
  @:noUsing static public function unit<I,E>():Resolve<I,E>{
    return lift(Fletcher.Sync((e:Err<E>) -> Tap));
  }

  public function prj():ResolveDef<I,E> return this;
  private var self(get,never):Resolve<I,E>;
  private function get_self():Resolve<I,E> return lift(this);
  @:to public inline function toFletcher():Fletcher<Err<E>,Chunk<I,E>,Noise>{
    return this;
  }
}
class ResolveLift{
  static public function toCascade<I,E>(self:Resolve<I,E>):Cascade<I,I,E>{
    return Cascade.lift(
        (i:Res<I,E>,cont:Terminal<Res<I,E>,Noise>) -> 
          i.fold(
            (s) -> cont.value(__.accept(s)).serve(),
            (e) -> {
              var next = Fletcher._.map(self,
                (chk:Chunk<I,E>) -> chk.fold(
                  (i) -> __.accept(i),
                  (e) -> __.reject(e),
                  ()  -> __.reject(e)//<-----
                )               
              );
              return cont.receive(next.forward(e));
            }
          )
    );
  }
}