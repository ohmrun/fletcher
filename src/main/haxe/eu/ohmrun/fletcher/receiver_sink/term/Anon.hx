package eu.ohmrun.fletcher.receiver_sink.term;

class Anon<R,E> extends ReceiverSinkCls<R,E>{
  public final _apply : ReceiverInput<R,E> -> Work;
  public function new(_apply){
    this._apply = _apply;
  }
  public inline function apply(p:ReceiverInput<R,E>) : Work{
    return _apply(p);
  }
}