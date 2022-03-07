package eu.ohmrun.fletcher;

typedef ReceiverSinkApi<R,E> = ApplyApi<ReceiverInput<R,E>,Work>;
typedef ReceiverSinkCls<R,E> = ApplyCls<ReceiverInput<R,E>,Work>;
typedef ReceiverSinkAbs<R,E> = Apply<ReceiverInput<R,E>,Work>;

@:forward abstract ReceiverSink<R,E>(ReceiverSinkApi<R,E>) from ReceiverSinkApi<R,E> to ReceiverSinkApi<R,E>{
  public function new(self) this = self;
  static public function lift<R,E>(self:ReceiverSinkApi<R,E>):ReceiverSink<R,E> return new ReceiverSink(self);
  @:from static public function fromApply<R,E>(self:Apply<ReceiverInput<R,E>,Work>){
    return lift(self);
  }
  public inline function seq(that:ReceiverSink<R,E>):ReceiverSink<R,E>{
    return lift(new eu.ohmrun.fletcher.receiver_sink.term.Seq(this,that));
  }
  static inline public function unit<R,E>():ReceiverSink<R,E>{
    return lift(new eu.ohmrun.fletcher.receiver_sink.term.Unit());
  }
  public function prj():ReceiverSinkApi<R,E> return this;
  private var self(get,never):ReceiverSink<R,E>;
  private function get_self():ReceiverSink<R,E> return lift(this);

  @:to public function toApply():ReceiverSinkAbs<R,E>{
    return Apply.lift(this);
  }
}