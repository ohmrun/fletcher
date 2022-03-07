package eu.ohmrun.fletcher.core.cont.term;

class AnonAnon<P,R> extends ContCls<P,R>{
  public final _apply : (P -> R) -> R;
  public function new(_apply){
    this._apply = _apply;
  }
  public inline function apply(p:Apply<P,R>):R{
    return _apply(p.apply);
  }
}