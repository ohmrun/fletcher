package eu.ohmrun.fletcher.core.cont.term;

class Anon<P,R> extends ContCls<P,R>{
  public final _apply : Apply<P,R> -> R;
  private var done    : Bool;
  public function new(_apply){
    super();
    this._apply = _apply;
    this.done   = false;
  }
  public inline function apply(p:Apply<P,R>):R{
    return if(!done){
      done = true;
      _apply(p);
    }else{
      throw 'already called';
    }
  }
}