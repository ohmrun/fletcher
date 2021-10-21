package eu.ohmrun.fletcher.core;

@:forward abstract Context<P,R,E>(ContextCls<P,R,E>) from ContextCls<P,R,E> to ContextCls<P,R,E>{
  @:noUsing static public function pure<P,R,E>(environment:P):Context<P,R,E>{
    return make(environment);
  }
  @:noUsing static public function make<P,R,E>(environment:P,?on_value:R->Void,?on_error:Defect<E>->Void):Context<P,R,E>{
    var result = new ContextCls(environment);
    if(__.option(on_value).is_defined()){
      result.on_value = on_value;
    }
    if(__.option(on_error).is_defined()){
      result.on_error = on_error;
    }
    return result;
  }
  @:from static public function fromInput<P,R,E>(environment:P):Context<P,R,E>{
    return make(environment);
  }
  public function load(arrowlet:Fletcher<P,R,E>):Fiber{
    return Fiber.lift(new Completion(this,arrowlet));
  }
}