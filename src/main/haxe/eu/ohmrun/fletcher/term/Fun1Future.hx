package eu.ohmrun.fletcher.term;

abstract class Fun1Future<P,R,E> implements FletcherApi<P,R,E> extends FletcherCls<P,R,E>{
  public function defer(p:P,cont:Terminal<R,E>):Work{
    return cont.receive(cont.later(future(p).map(__.success)));
  }
  abstract function future(p:P):Future<R>;
}