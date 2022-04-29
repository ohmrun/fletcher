package eu.ohmrun.fletcher;

typedef VentureDef<P,R,E> = FletcherApi<P,Receipt<R,E>,Noise>;

@:using(eu.ohmrun.fletcher.Venture.VentureLift)
abstract Venture<P,R,E>(VentureDef<P,R,E>) from VentureDef<P,R,E> to VentureDef<P,R,E>{
  static public var _(default,never) = VentureLift;
  public inline function new(self:VentureDef<P,R,E>) this = self;
  @:noUsing static inline public function lift<P,R,E>(self:VentureDef<P,R,E>):Venture<P,R,E> return new Venture(self);

  public function prj():VentureDef<P,R,E> return this;
  private var self(get,never):Venture<P,R,E>;
  private function get_self():Venture<P,R,E> return lift(this);

  @:from static public function fromFun<P,R,E>(fn:P->Receipt<R,E>){
    return lift(Fletcher.Sync(fn));
  }
}
class VentureLift{
  static public inline function lift<P,R,E>(self:VentureDef<P,R,E>):Venture<P,R,E>{
    return Venture.lift(self);
  }
}