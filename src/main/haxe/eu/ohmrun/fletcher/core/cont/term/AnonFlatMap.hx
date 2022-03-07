package eu.ohmrun.fletcher.core.cont.term;

class AnonFlatMap<P,Pi,R> extends FlatMap<P,Pi,R>{
  private final _flat_map : P -> Cont<Pi,R>;

  public function new(delegate,_flat_map){
    super(delegate);
    this._flat_map = _flat_map;
  }

  private inline function flat_map(p:P):Cont<Pi,R>{
    return _flat_map(p);
  }
}