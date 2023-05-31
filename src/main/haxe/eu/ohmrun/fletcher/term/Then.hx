package eu.ohmrun.fletcher.term;

/**
 * Left-to-right combinator
 */
class Then<P,Ri,Rii,E> extends FletcherCls<P,Rii,E>{
  public final lhs : Fletcher<P,Ri,E>;
  public final rhs : Fletcher<Ri,Rii,E>;
  public function new(lhs,rhs,?pos:Pos){
    super(pos);
    this.lhs = lhs;
    this.rhs = rhs;
  }
  public function defer(pI:P,cont:Terminal<Rii,E>):Work{
    __.log().trace('$source $pI');
    var a = lhs.forward(pI);
    return cont.receive(a.flat_fold(
      ok -> rhs.forward(ok),
      no -> Receiver.error(no)
    ));
  }
}