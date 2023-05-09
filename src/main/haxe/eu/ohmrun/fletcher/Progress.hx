package eu.ohmrun.fletcher;

class Progress<R,E>{
  // public function close(term):Progress<R,E>{
  //   return wait(process(term));
  // }
  private function new(explain,closure,product,failure){
    this.explain = explain;
    this.closure = closure;
    this.product = product;
    this.failure = failure;
  }
  public final explain    : Explain;
  public final closure    : Null<Work>;
  public final product    : Null<R>;
  public final failure    : Null<Defect<E>>;

  // public function process(v:Progess<R,E>):Progress<Nada,Nada>{

  // }
  // @:noUsing static public function issue<R,E>(outcome:Outcome<R,Defect<E>>,?pos:Pos):Progress<R,E>{
  //   return new Pro(
  //     Cont.Anon((fn:Apply<ReceiverInput<R,E>,Work>) -> {
  //       var t = Future.trigger();
  //           t.trigger(outcome);
  //       return fn.apply(t.asFuture());
  //     })
  //   );
  // }
}