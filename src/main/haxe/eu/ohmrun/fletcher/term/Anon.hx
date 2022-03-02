package eu.ohmrun.fletcher.term;

class Anon<P,R,E> implements FletcherApi<P,R,E>{
  final _defer : (p:P,cont:Terminal<R,E>) -> Work;

  public function new(_defer){
    this._defer = _defer;
  }
  public function defer(p:P,cont:Terminal<R,E>):Work{
    return _defer(p,cont);
  }  
}