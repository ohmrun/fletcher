package eu.ohmrun.fletcher.core.cont.term;

class Anon<P,R> extends ContCls<P,R>{
  public final _apply : Apply<P,R> -> R;
  public function new(_apply){
    this._apply = _apply;
  }
  public inline function apply(p:Apply<P,R>):R{
    return _apply(p);
  }
}