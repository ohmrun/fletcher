package eu.ohmrun.fletcher.term;

class AnonSync<Pi,Pii,E> extends Sync<Pi,Pii,E>{
  final _apply : Pi -> Pii;
  public function new(_apply,?pos:Pos){
    super(pos);
    this._apply = _apply;
  }
  public inline function apply(p:Pi){
    return __.success(_apply(p));
  }
}