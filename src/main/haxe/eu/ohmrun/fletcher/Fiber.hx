package eu.ohmrun.fletcher;

typedef FiberDef = Fletcher<Noise,Noise,Noise>;

@:using(eu.ohmrun.fletcher.Fiber.FiberLift)
@:forward abstract Fiber(FiberDef) from FiberDef{
  static public var _(default,never) = FiberLift;
  static public inline function lift(self:Fletcher<Noise,Noise,Noise>):Fiber{
    return self;
  }
  public inline function submit():Void{
    this(
      Noise,
      Terminal.lift((fn) -> fn(null))
    ).toCycle()
     .submit();
  }
  public inline function crunch():Void{
    this(
      Noise,
      Terminal.lift((fn) -> fn(null))
    ).toCycle()
     .crunch();
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