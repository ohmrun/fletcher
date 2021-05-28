package eu.ohmrun.fletcher;

typedef PerformDef = FletcherDef<Noise,Noise,Noise>;

abstract Perform(PerformDef) from PerformDef to PerformDef{
  public inline function new(self) this = self;
  static public inline function lift(self:PerformDef):Perform return new Perform(self);
  
  
  public inline function toFletcher():Fletcher<Noise,Noise,Noise> return this;
  public function toCascade<E>():Cascade<Noise,Noise,E>{
    return Cascade.lift(
      Fletcher.Anon(
        (_:Res<Noise,E>,cont:Terminal<Res<Noise,E>,Noise>) -> {
          return cont.receive(
            Fletcher._.map(this,(_:Noise) -> __.accept(_)).forward(Noise)
          );
        }
      )
    );
  }
  public function prj():PerformDef return this;
  private var self(get,never):Perform;
  private function get_self():Perform return lift(this);
}