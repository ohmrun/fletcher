package eu.ohmrun.fletcher;

interface ReachApi<P,R,E>{
  public function apply(p:P,term:Terminal<R,E>):Progress<R,E>;
}
abstract class ReachCls<P,R,E> implements ReachApi<P,R,E>{
  abstract public function apply(p:P,term:Terminal<R,E>):Progress<R,E>;
}
class AnonReach<P,R,E> extends ReachCls<P,R,E>{
  public function new(_apply){
    this._apply = _apply;
  }
  final _apply : P -> Terminal<R,E> -> Progress<R,E>;

  inline public function apply(p:P,term:Terminal<R,E>):Progress<R,E>{
    return _apply(p,term);
  }
}
class PureReach<P,R,E> extends ReachCls<P,R,E>{
  final result : ArwOut<R,E>;
  public function new(result){
    this.result = result;
  }
  inline public function apply(p:P,term:Terminal<R,E>):Progress<R,E>{
    //return Progress.done(result);
    return throw UNIMPLEMENTED;
  }
}
@:using(eu.ohmrun.fletcher.Reach.ReachLift)
@:forward abstract Reach<P,R,E>(ReachApi<P,R,E>) from ReachApi<P,R,E> to ReachApi<P,R,E>{
  static public var _(default,never) = ReachLift;
  public inline function new(self:ReachApi<P,R,E>) this = self;
  @:noUsing static inline public function lift<P,R,E>(self:ReachApi<P,R,E>):Reach<P,R,E> return new Reach(self);

  public function prj():ReachApi<P,R,E> return this;
  private var self(get,never):Reach<P,R,E>;
  private function get_self():Reach<P,R,E> return lift(this);
}
class ReachLift{
  static public inline function lift<P,R,E>(self:ReachApi<P,R,E>):Reach<P,R,E>{
    return Reach.lift(self);
  }
  static public function then<Pi,Ri,Rii,E>(lhs:ReachApi<Pi,Ri,E>,rhs:ReachApi<Ri,Rii,E>):ReachApi<Pi,Rii,E>{
    return new AnonReach(
      (p:Pi,term:Terminal<Rii,E>) -> {
        //$type(lhs.apply);
        //final a = lhs.apply(p,term);
        return null;
        // return rI.ready ? 
        //   rI.fold(
        //     x -> rhs.apply(x,term),
        //     e -> new PureReach(__.failure(e))
        //   )
        // :
        //   null;
          //rI.close(term);
      }
    );
  }
  //static public function forward<P,Pi,E>(f:ReachApi<P,Pi,E>,p:P):Receiver<Pi,E>{
}