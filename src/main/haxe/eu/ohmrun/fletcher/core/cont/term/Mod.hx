package eu.ohmrun.fletcher.core.cont.term;

abstract class Mod<P,R> extends Delegate<Cont<P,R>,P,R>{
  abstract public function mod(r:R):R;
  public inline function apply(fn:Apply<P,R>):R{
    return mod(delegate.apply(fn));
  }
}