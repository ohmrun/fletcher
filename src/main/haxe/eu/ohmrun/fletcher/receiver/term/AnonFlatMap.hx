package eu.ohmrun.fletcher.receiver.term;

abstract class AnonFlatMap<P,Pi,E> extends FlatMap<P,Pi,E>{
  public final _ok : P -> Receiver<Pi,E>;
  public function new(self,_ok){
    super(self);
    this._ok = _ok;
  }
 public inline function ok(p:P):Receiver<Pi,E>{
    return _ok(p);
  }
}