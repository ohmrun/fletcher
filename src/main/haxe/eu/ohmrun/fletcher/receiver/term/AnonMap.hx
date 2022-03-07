package eu.ohmrun.fletcher.receiver.term;

abstract class AnonMap<R,Ri,E> extends Map<R,Ri,E>{
  public function new(delegate,_map){
    super(delegate);
    this._map = _map;
  }
  public final _map : R -> Ri;
  public inline function map(r:R):Ri{
    return _map(r);
  }
}