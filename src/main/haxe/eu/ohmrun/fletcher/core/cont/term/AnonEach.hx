package eu.ohmrun.fletcher.core.cont.term;

class AnonEach<P,R> extends Each<P,R>{
  public final _each : P -> Void;
  public function new(delegate,_each){
    super(delegate);
    this._each = _each;
  } 
  public inline function each(p:P):Void{
    _each(p);
  }
}