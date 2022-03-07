package eu.ohmrun.fletcher.receiver.term;

abstract class FlatMap<P,Pi,E> extends FlatFold<P,Pi,E>{
  public function new(self){
    super(self);
  }
  abstract public function ok(p:P):Receiver<Pi,E>;

  public function no(d:Defect<E>):Receiver<Pi,E>{
    return Receiver.issue(Failure(d));
  }
  
}