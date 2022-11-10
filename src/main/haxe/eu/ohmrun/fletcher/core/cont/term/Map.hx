package eu.ohmrun.fletcher.core.cont.term;

abstract class Map<P,Pi,R> extends Delegate<Cont<P,R>,Pi,R>{

  abstract private function map(p:P):Pi;

  public function apply(fn:Apply<Pi,R>):R{
    __.log().trace('map $this');
    return delegate.apply(
      Apply.Anon(
        (p:P) -> {
          __.log().trace('map $this apply');
          __.log().trace('map $delegate apply');
          
          final next = map(p);
          final done = fn.apply(next);
          __.log().trace('$done');
          return done;
        }
      )
    );
  }
}