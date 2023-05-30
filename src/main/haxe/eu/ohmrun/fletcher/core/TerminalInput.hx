package eu.ohmrun.fletcher.core;

typedef TerminalInputDef<R,E> = FutureTrigger<ArwOut<R,E>>;

@:forward abstract TerminalInput<R,E>(TerminalInputDef<R,E>) from TerminalInputDef<R,E> to TerminalInputDef<R,E>{
  public function new(self) this = self;
  @:noUsing static public inline function lift<R,E>(self:TerminalInputDef<R,E>):TerminalInput<R,E> return new TerminalInput(self);

  public function prj():TerminalInputDef<R,E> return this;
  private var self(get,never):TerminalInput<R,E>;
  private function get_self():TerminalInput<R,E> return lift(this);

  public inline function toReceiverInput(){
    return ReceiverInput.lift(this.asFuture());
  }
  @:noUsing static public inline function unit<R,E>():TerminalInput<R,E>{
    return Future.trigger();
  }
}