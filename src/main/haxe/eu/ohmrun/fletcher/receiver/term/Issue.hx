package eu.ohmrun.fletcher.receiver.term;

class Issue<P,E> extends eu.ohmrun.fletcher.core.cont.term.Map<TerminalInput<P,E>,ReceiverInput<P,E>,Work>{
  final outcome : Outcome<P,Defect<E>>;
  public function new(delegate,outcome){
    super(delegate);
    this.outcome = outcome;
  }
  public function map(r:TerminalInput<P,E>):ReceiverInput<P,E>{
    return r.toReceiverInput();
  }
  override inline public function apply(app:Apply<ReceiverInput<P,E>,Work>):Work{
    return delegate.apply(
      Apply.Anon(
        (p:TerminalInput<P,E>) -> {
          p.trigger(outcome);
          return app.apply(map(p));
        }
      )
    );
  }
}