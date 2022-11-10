package eu.ohmrun.fletcher.core.cont.term;

abstract class Delegate<T,P,R> extends ContCls<P,R>{
  public final delegate : T;
  public function new(delegate){
    super();
    this.delegate = delegate;
  }
}