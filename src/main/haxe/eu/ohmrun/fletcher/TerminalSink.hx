package eu.ohmrun.fletcher;

typedef TerminalSinkDef<R,E>    = ArwOut<R,E>     -> Work;

@:forward @:callable abstract TerminalSink<R,E>(TerminalSinkDef<R,E>) from TerminalSinkDef<R,E> to TerminalSinkDef<R,E>{
  public function new(self) this = self;
  static public function lift<R,E>(self:TerminalSinkDef<R,E>):TerminalSink<R,E> return new TerminalSink(self);

  public function seq(that:TerminalSink<R,E>):TerminalSink<R,E>{
    return lift((oc:ArwOut<R,E>) -> {
      return this(oc).seq(that(oc));
    });
  }
  static public function unit<R,E>():TerminalSink<R,E>{
    return (x:ArwOut<R,E>)  ->  Work.unit();
  }
  static public function pull<R,E>(fn:ArwOut<R,E>->Void):TerminalSink<R,E>{
    return lift((x:ArwOut<R,E>)  ->  {
      fn(x);
      return Work.unit();
    });
  }
  public function prj():TerminalSinkDef<R,E> return this;
  private var self(get,never):TerminalSink<R,E>;
  private function get_self():TerminalSink<R,E> return lift(this);

  public function reply(){
    return this(null);
  }
}