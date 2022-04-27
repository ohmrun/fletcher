package eu.ohmrun.fletcher;

typedef FiberDef = Fletcher<Noise,Noise,Noise>;

@:using(eu.ohmrun.fletcher.Fiber.FiberLift)
@:forward abstract Fiber(FiberDef) from FiberDef{
  static public var _(default,never) = FiberLift;
  static public inline function lift(self:Fletcher<Noise,Noise,Noise>):Fiber{
    return self;
  }
  public inline function work():Work{
    return this.defer(
      Noise,
      Terminal.unit()
    );
  }
  public inline function cycle():Cycle{
    return work().toCycle();
  }
  public inline function submit():Void{
    return cycle().submit();
  }
  public inline function crunch():Void{
    cycle().crunch();
  }
  @:from static public function fromCompletion<P,R,E>(self:Completion<P,R,E>){
    return lift(Fletcher.lift(self));
  }
  public function prj():FletcherDef<Noise,Noise,Noise>{
    return this;
  }
}
class FiberLift{
  static public function then<O>(self:Fiber,that:Provide<O>):Provide<O>{
    return Provide.lift(Fletcher.Then(
      self.prj(),
      that
    ));
  }
}