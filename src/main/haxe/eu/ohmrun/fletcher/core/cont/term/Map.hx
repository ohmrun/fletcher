package eu.ohmrun.fletcher.core.cont.term;

abstract class Map<P,Pi,R> extends Delegate<Cont<P,R>,Pi,R>{

  abstract private function map(p:P):Pi;

  public function apply(fn:Apply<Pi,R>):R{
    return delegate.apply(
      Apply.Anon((p:P) -> fn.apply(map(p)))
    );
  }
}