package eu.ohmrun.fletcher.core.cont.term;

class AnonMod<P,R> extends Mod<P,R>{
  public final _mod : R -> R;
  public function new(delegate,_mod){
    super(delegate);
    this._mod = _mod;
  }
  public inline function mod(r:R):R{
    return _mod(r);
  }
}