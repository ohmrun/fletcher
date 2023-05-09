package eu.ohmrun.fletcher;

typedef PerformDef = FletcherDef<Nada,Nada,Nada>;

abstract Perform(PerformDef) from PerformDef to PerformDef{
  public inline function new(self) this = self;
  static public inline function lift(self:PerformDef):Perform return new Perform(self);
  
  
  public inline function toFletcher():Fletcher<Nada,Nada,Nada> return this;
  public function toModulate<E>():Modulate<Nada,Nada,E>{
    return Modulate.lift(
      Fletcher.Anon(
        (_:Upshot<Nada,E>,cont:Terminal<Upshot<Nada,E>,Nada>) -> {
          return cont.receive(
            //CPP fix 08/11/22
            Fletcher.FletcherLift.map(this,(_:Nada) -> __.accept(_)).forward(Nada)
          );
        }
      )
    );
  }
  public function prj():PerformDef return this;
  private var self(get,never):Perform;
  private function get_self():Perform return lift(this);
}