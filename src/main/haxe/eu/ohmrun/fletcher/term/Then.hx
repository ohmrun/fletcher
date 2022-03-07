package eu.ohmrun.fletcher.term;

class Then<P,Ri,Rii,E> extends FletcherCls<P,Rii,E>{
  public final lhs : Fletcher<P,Ri,E>;
  public final rhs : Fletcher<Ri,Rii,E>;
  public function new(lhs,rhs){
    super();
    this.lhs = lhs;
    this.rhs = rhs;
  }
  public function defer(pI:P,cont:Terminal<Rii,E>):Work{
    var a = lhs.forward(pI);
    return cont.receive(a.flat_fold(
      ok -> rhs.forward(ok),
      no -> Receiver.error(no)
    ));
  }
}