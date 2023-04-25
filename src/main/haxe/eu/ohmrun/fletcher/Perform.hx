package eu.ohmrun.fletcher;

typedef PerformDef = FletcherDef<Noise,Noise,Noise>;

abstract Perform(PerformDef) from PerformDef to PerformDef{
  public inline function new(self) this = self;
  static public inline function lift(self:PerformDef):Perform return new Perform(self);
  
  
  public inline function toFletcher():Fletcher<Noise,Noise,Noise> return this;
  public function toModulate<E>():Modulate<Noise,Noise,E>{
    return Modulate.lift(
      Fletcher.Anon(
        (_:Upshot<Noise,E>,cont:Terminal<Upshot<Noise,E>,Noise>) -> {
          return cont.receive(
            //CPP fix 08/11/22
            Fletcher.FletcherLift.map(this,(_:Noise) -> __.accept(_)).forward(Noise)
          );
        }
      )
    );
  }
  public function prj():PerformDef return this;
  private var self(get,never):Perform;
  private function get_self():Perform return lift(this);
}