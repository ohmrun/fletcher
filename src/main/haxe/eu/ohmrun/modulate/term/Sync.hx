package eu.ohmrun.cascade.term;

abstract class Sync<P,Pi,E> implements FletcherApi<Res<P,E>,Res<Pi,E>,Noise> {
  public function defer(p:Res<P,E>,cont:Terminal<Res<Pi,E>, Noise>):Work{
    return cont.receive(cont.issue(apply(p)));
  }
  abstract function apply(v:Res<P,E>):ArwOut<Res<Pi,E>,Noise>;
}