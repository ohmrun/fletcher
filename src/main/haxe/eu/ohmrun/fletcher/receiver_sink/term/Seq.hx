package eu.ohmrun.fletcher.receiver_sink.term;

class Seq<R,E> extends ReceiverSinkCls<R,E>{
  public final lhs : ReceiverSink<R,E>;
  public final rhs : ReceiverSink<R,E>;
  public function new(lhs,rhs){
    this.lhs = lhs;
    this.rhs = rhs;
  }
  public inline function apply(p:ReceiverInput<R,E>) : Work{
    return lhs.apply(p).seq(rhs.apply(p));
  }
}