package eu.ohmrun.fletcher.core;

class ThenApi<P,Ri,Rii,E> extends TaskApi<Rii,E>{
  public final lhs        : BridgeApi<P,Ri,E>;
  public final rhs        : BridgeApi<Ri,Rii,E>;

  public final arrow_type : ArrowType;
}
class ThenCls<P,Ri,Rii,E> implements ThenApi<P,Ri,Rii,E> extends Task<Rii,E>{
  public final lhs        : BridgeApi<P,Ri,E>;
  public final rhs        : BridgeApi<Ri,Rii,E>;

  public function new(lhs,rhs){
    this.lhs        = lhs;
    this.rhs        = rhs;
    this.task_type  = TaskThroughBind;
    this.arrow_type = ArrowThen;
  }
  // public function reply(){
  //   return switch(lhs)
  // }
}
class ThenClsLift{
  static public function apply<P,Ri,Rii,E>(lhs:BridgeApi<P,Ri,E>,rhs:Bridge<Ri,Rii,E>){
    
  }
}