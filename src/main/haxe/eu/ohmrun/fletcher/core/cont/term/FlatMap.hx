package eu.ohmrun.fletcher.core.cont.term;

abstract class FlatMap<P,Pi,R> extends Delegate<Cont<P,R>,Pi,R>{

  abstract private function flat_map(p:P):Cont<Pi,R>;

  public function apply(fn:Apply<Pi,R>):R{
    return delegate.apply(
      Apply.Anon((p:P) -> flat_map(p).apply(fn))
    );
  }
}