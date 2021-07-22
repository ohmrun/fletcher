package eu.ohmrun.fletcher.core;

class ContextCls<P,R,E>{
  public var environment(default,null):P;
  public function new(environment){
    this.environment = environment;
  }
  public dynamic function on_error(e:Defect<E>):Void{
    __.crack(e);
  }
  public dynamic function on_value(r:R):Void{
    __.log().debug((ctr) -> ctr.pure(r));
  }
}