package eu.ohmrun.fletcher.receiver.term;

abstract class FlatFold<P,Pi,E> extends ReceiverCls<Pi,E>{
  public final self : Receiver<P,E>;
  public function new(self){
    super();
    this.self = self;
  }
  abstract public function ok(p:P):Receiver<Pi,E>;
  abstract public function no(d:Defect<E>):Receiver<Pi,E>;

  public function apply(app:Apply<ReceiverInput<Pi,E>,Work>):Work{
    return self.apply(
      Apply.Anon(
        (p:ReceiverInput<P,E>) -> {
          final data = p.flatMap(
            (out:ArwOut<P,E>) -> {
              return out.fold(ok,no);
            }
          ).flatMap(
            (rec:Receiver<Pi,E>) -> rec.apply(app)
          );
          return Work.fromFutureWork(data);
        }
      )
    );
  }
}