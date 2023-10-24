package eu.ohmrun.fletcher;

typedef FiberDef = Fletcher<Nada,Nada,Nada>;

@:using(eu.ohmrun.fletcher.Fiber.FiberLift)
@:forward abstract Fiber(FiberDef) from FiberDef{
  static public var _(default,never) = FiberLift;
  static public inline function lift(self:Fletcher<Nada,Nada,Nada>):Fiber{
    return self;
  }
  public inline function work():Work{
    return this.defer(
      Nada,
      Terminal.unit()
    );
  }
  public inline function cycle():Cycle{
    return work().toCycle();
  }
  public inline function submit(?pos:Pos):Void{
    return cycle().submit(pos);
  }
  public inline function crunch():Void{
    cycle().crunch();
  }
  @:from static public function fromCompletion<P,R,E>(self:Completion<P,R,E>){
    return lift(Fletcher.lift(self));
  }
  @:from static public function fromFuture(self:Future<Nada>){
    return lift(
      Fletcher.Anon((_:Nada,cont:Terminal<Nada,Nada>) -> {
        return cont.receive(cont.later(self.map(Success)));
      })
    );
  }
  @:to public function reply():Future<Nada>{
    final trigger = Future.trigger();
    final next    = 
      FiberLift.seq(this,lift(
        Fletcher.Anon((_:Nada,cont:Terminal<Nada,Nada>) -> {
          trigger.trigger(Nada);
          return cont.receive(cont.value(Nada));
        })
      ));
    next.submit();
    return trigger.asFuture();
  }
  public function prj():FletcherDef<Nada,Nada,Nada>{
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
  static public function seq(self:Fiber,that:Fiber):Fiber{
    return Fiber.lift(
      Fletcher.Then(self.toFletcher(),that.toFletcher())
    );
  }
}