package eu.ohmrun.fletcher.receiver.term;

class Thunk<P,E> extends Delegate<Void->Receiver<P,E>,P,E>{
  public function new(delegate){
    super(delegate);
  }
  public inline function apply(fn:Apply<ReceiverInput<P,E>,Work>):Work{
    return delegate().apply(fn);
  }
}