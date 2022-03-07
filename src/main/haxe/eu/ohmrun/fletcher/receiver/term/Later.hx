package eu.ohmrun.fletcher.receiver.term;

class Later<R,E> extends Delegate<Terminal<R,E>,R,E>{
  final future : Future<Outcome<R,Defect<E>>>;
  public function new(delegate,future){
    super(delegate);
    this.future = future;
  }
  public function apply(app:Apply<ReceiverInput<R,E>,Work>):Work{
    return this.delegate.apply(
      Apply.Anon((trig:TerminalInput<R,E>) -> {
        future.handle(
          (x:Outcome<R,Defect<E>>) -> trig.trigger(x)
        );
        return app.apply(trig.toReceiverInput());
      })
    );
  }
}