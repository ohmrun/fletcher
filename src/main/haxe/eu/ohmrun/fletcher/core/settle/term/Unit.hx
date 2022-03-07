package eu.ohmrun.fletcher.core.settle.term;

class Unit<P> extends SettleCls<P>{
  public function new(){}
  public function apply(fn:Apply<P,Work>):Work{
    return Work.unit();
  }
}