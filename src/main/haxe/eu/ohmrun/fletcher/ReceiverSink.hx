package eu.ohmrun.fletcher;

typedef ReceiverSinkDef<R,E>    = ReceiverInput<R,E>     -> Work;

@:forward @:callable abstract ReceiverSink<R,E>(ReceiverSinkDef<R,E>) from ReceiverSinkDef<R,E> to ReceiverSinkDef<R,E>{
  public function new(self) this = self;
  static public function lift<R,E>(self:ReceiverSinkDef<R,E>):ReceiverSink<R,E> return new ReceiverSink(self);

  public function seq(that:ReceiverSink<R,E>):ReceiverSink<R,E>{
    return lift((oc:ReceiverInput<R,E>) -> {
      return this(oc).seq(that(oc));
    });
  }
  static public function unit<R,E>():ReceiverSink<R,E>{
    return lift((x:ReceiverInput<R,E>)  ->  Work.unit());
  }
  public function prj():ReceiverSinkDef<R,E> return this;
  private var self(get,never):ReceiverSink<R,E>;
  private function get_self():ReceiverSink<R,E> return lift(this);
}