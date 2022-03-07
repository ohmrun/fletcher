package eu.ohmrun.fletcher.receiver_sink.term;

class Unit<R,E> extends ReceiverSinkCls<R,E>{
  public function new(){}
  public inline function apply(p:ReceiverInput<R,E>) : Work{
    return Work.unit();
  }
}