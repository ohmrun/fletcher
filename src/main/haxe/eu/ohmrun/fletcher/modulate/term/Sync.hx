package eu.ohmrun.fletcher.modulate.term;

abstract class Sync<P,Pi,E> implements FletcherApi<Upshot<P,E>,Upshot<Pi,E>,Noise> {
  public function defer(p:Upshot<P,E>,cont:Terminal<Upshot<Pi,E>, Noise>):Work{
    return cont.receive(cont.issue(apply(p)));
  }
  abstract function apply(v:Upshot<P,E>):ArwOut<Upshot<Pi,E>,Noise>;
}