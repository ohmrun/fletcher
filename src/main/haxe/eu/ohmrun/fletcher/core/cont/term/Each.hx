package eu.ohmrun.fletcher.core.cont.term;

abstract class Each<P,R> extends Delegate<Cont<P,R>,P,R>{
  public function new(delegate){
    super(delegate);
  }
  abstract public function each(p:P):Void; 

  public function apply(fn:Apply<P,R>):R{
    return delegate.apply(
      Apply.Anon(
        (p:P) -> {
          each(p);
          return fn.apply(p);
        }
      )
    );
  }
}