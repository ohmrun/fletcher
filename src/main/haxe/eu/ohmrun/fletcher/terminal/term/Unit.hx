package eu.ohmrun.fletcher.terminal.term;

class Unit<P,E> extends TerminalCls<P,E>{
  public function apply(p:Apply<TerminalInput<P,E>,Work>):Work{
    return p.apply(TerminalInput.unit());
  }
}