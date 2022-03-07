package eu.ohmrun.fletcher.core.cont.term;

class AnonMap<P,Pi,R> extends Map<P,Pi,R>{
  public function new(delegate,_map){
    super(delegate);
    this._map = _map;
  }
  private final _map : P -> Pi;

  private inline function map(p:P):Pi{
    return _map(p);
  }
}