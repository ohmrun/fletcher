package eu.ohmrun.fletcher.core.settle.term;

class Pure<P> extends SettleCls<P>{
  public final value : P;
  public function new(value){
    super();
    this.value = value;
  }
  public inline function apply(fn:Apply<P,Work>):Work{
    return fn.apply(value);
  }
}