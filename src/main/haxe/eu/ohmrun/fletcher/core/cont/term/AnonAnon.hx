package eu.ohmrun.fletcher.core.cont.term;

class AnonAnon<P,R> extends ContCls<P,R>{
  public final pos    : Position;
  public final _apply : (P -> R) -> R;
  private var res     : R;

  public function new(_apply,?pos:Pos){
    super();
    this._apply = _apply;
    this.pos    = pos;
  }
  public inline function apply(p:Apply<P,R>):R{
    __.log().trace('$p $pos');
    res = _apply(p.apply);
    return res;
  }
}