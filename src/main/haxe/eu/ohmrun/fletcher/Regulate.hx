package eu.ohmrun.fletcher;

typedef RegulateDef<R,E> = ModulateDef<R,R,E>;

@:using(eu.ohmrun.fletcher.Modulate.ModulateLift)
abstract Regulate<R,E>(RegulateDef<R,E>) from RegulateDef<R,E> to RegulateDef<R,E>{
  static public var _(default,never) = RegulateLift;  
  public function new(self) this = self;
  static public function lift<R,E>(self:RegulateDef<R,E>):Regulate<R,E> return new Regulate(self);

  public function prj():RegulateDef<R,E> return this;
  private var self(get,never):Regulate<R,E>;
  private function get_self():Regulate<R,E> return lift(this);
}

class RegulateLift{

}