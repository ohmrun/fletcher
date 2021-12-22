package eu.ohmrun.fletcher.term;

abstract class Sync<P,Pi,E> implements FletcherApi<P,Pi,E> {
  public function defer(p:P,cont:Terminal<Pi,E>):Work{
    return cont.receive(cont.issue(apply(p)));
  }
  abstract function apply(v:P):ArwOut<Pi,E>;
}