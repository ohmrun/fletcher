package eu.ohmrun.fletcher.receiver.term;

abstract class AnonFlatFold<P,Pi,E> extends FlatFold<P,Pi,E>{
  public function new(self,_ok,_no){
    super(self);
    this._ok  = _ok;
    this._no  = _no;
  }
  public final _ok : P -> Receiver<Pi,E>;
  public inline function ok(p:P):Receiver<Pi,E>{
    return _ok(p);
  }
  public final _no : Defect<E> -> Receiver<Pi,E>;
  public inline function no(d:Defect<E>):Receiver<Pi,E>{
    return _no(d);
  }
}