package eu.ohmrun.fletcher.receiver.term;

abstract class Delegate<T,R,E> extends ReceiverCls<R,E>{
  private final delegate : T; 
  public function new(delegate){
    this.delegate = delegate;
  }
}