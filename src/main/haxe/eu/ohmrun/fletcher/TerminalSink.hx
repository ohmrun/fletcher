package eu.ohmrun.fletcher;

typedef TerminalSinkDef<R,E>    = TerminalInput<R,E>     -> Work;

@:forward @:callable abstract TerminalSink<R,E>(TerminalSinkDef<R,E>) from TerminalSinkDef<R,E> to TerminalSinkDef<R,E>{
  public function new(self) this = self;
  static public function lift<R,E>(self:TerminalSinkDef<R,E>):TerminalSink<R,E> return new TerminalSink(self);

  public function seq(that:TerminalSink<R,E>):TerminalSink<R,E>{
    return lift((oc:TerminalInput<R,E>) -> {
      return this(oc).seq(that(oc));
    });
  }
  static public function unit<R,E>():TerminalSink<R,E>{
    return (x:TerminalInput<R,E>)  ->  Work.unit();
  }
  static public function pull<R,E>(fn:TerminalInput<R,E>->Void):TerminalSink<R,E>{
    return lift((x:TerminalInput<R,E>)  ->  {
      fn(x);
      return Work.unit();
    });
  }
  public function prj():TerminalSinkDef<R,E> return this;
  private var self(get,never):TerminalSink<R,E>;
  private function get_self():TerminalSink<R,E> return lift(this);

  public function reply(){
    return this(Future.trigger());
  }
}