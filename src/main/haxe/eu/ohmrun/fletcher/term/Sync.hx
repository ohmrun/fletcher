package eu.ohmrun.fletcher.term;

abstract class Sync<P,Pi,E> implements FletcherApi<P,Pi,E> {
  public final source : Position;
  public function new(?pos:Pos){
    this.source = pos;
  }
  public function defer(p:P,cont:Terminal<Pi,E>):Work{
    return cont.receive(cont.issue(apply(p)));
  }
  abstract function apply(v:P):ArwOut<Pi,E>;
  public var stx_tag(get,null):Int;
  public function get_stx_tag():Int{
    return -1;
  }
  public function toFletcher(){
    return this;
  }
}