package eu.ohmrun.fletcher.core.cont.term;

abstract class ZipWith<P,Pi,Pii,R> extends ContCls<Pii,R>{
  public final lhs : Cont<P,R>;
  public final rhs : Cont<Pi,R>;

  public function new(lhs,rhs){
    super();
    this.lhs = lhs;
    this.rhs = rhs;
  }
  abstract private function zip(l:P,r:Pi):Pii;

  public function apply(fn:Apply<Pii,R>):R{
    return lhs.apply(
      Apply.Anon((p:P) -> rhs.apply(
        Apply.Anon((pI:Pi) -> fn.apply(zip(p,pI)))
      ))
    );
  }
}