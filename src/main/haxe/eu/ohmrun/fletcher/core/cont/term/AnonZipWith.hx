package eu.ohmrun.fletcher.core.cont.term;

class AnonZipWith<P,Pi,Pii,R> extends ZipWith<P,Pi,Pii,R>{

  public final _zip : P -> Pi -> Pii;
  public function new(lhs,rhs,_zip){
    super(lhs,rhs);
    this._zip = _zip;
  }
  private inline function zip(l:P,r:Pi):Pii{
    return _zip(l,r);
  }
}