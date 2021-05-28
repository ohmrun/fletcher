package eu.ohmrun.fletcher;

typedef ConvertDef<I,O> = FletcherDef<I,O,Noise>;

/**
  An Fletcher with no fail case
**/
@:using(eu.ohmrun.fletcher.Convert.ConvertLift)
abstract Convert<I,O>(ConvertDef<I,O>) from ConvertDef<I,O> to ConvertDef<I,O>{
  static public var _(default,never) = ConvertLift;
  public inline function new(self) this = self;
  @:noUsing static public inline function lift<I,O>(self:ConvertDef<I,O>):Convert<I,O> return new Convert(self);
  @:noUsing static public inline function unit<I>():Convert<I,I> return lift(Fletcher.Sync((i:I)->i));

  @:noUsing static public function fromFun1Provide<I,O>(self:I->Provide<O>):Convert<I,O>{
    return lift(
      (i:I,cont:Terminal<O,Noise>) -> cont.receive(self(i).forward(Noise))
    );
  }
  @:noUsing static public function fromConvertProvide<P,R>(self:Convert<P,Provide<R>>):Convert<P,R>{
    return lift(
      (p:P,con) -> self.forward(p).flat_fold(
        (ok:Provide<R>)   -> ok.forward(Noise),
        (er)              -> Receiver.error(er)
      ).serve()
    );
  }
  
  @:to public inline function toFletcher():Fletcher<I,O,Noise>{
    return this;
  }
  private var self(get,never):Convert<I,O>;
  private function get_self():Convert<I,O> return lift(this);

  public function toCascade<E>():Cascade<I,O,E>{
    return Cascade.lift(
      (p:Res<I,E>,cont:Waypoint<O,E>) -> p.fold(
        ok -> cont.receive(this.forward(ok).map(__.accept)),
        no -> cont.value(__.reject(no)).serve()
      ) 
    );
  }
  @:from static public function fromFun1R<I,O>(fn:I->O):Convert<I,O>{
    return lift(Fletcher.fromFun1R(fn));
  }
  
  @:from static public function fromFletcher<I,O>(arw:Fletcher<I,O,Noise>){
    return lift(arw);
  }
  public inline function environment(i:I,success:O->Void):Fiber{
    return Fletcher._.environment(
      this,
      i,
      success,
      __.crack
    );
  }
}
class ConvertLift{
  static public function then<I,O,Oi>(self:ConvertDef<I,O>,that:Convert<O,Oi>):Convert<I,Oi>{
    return Convert.lift(Fletcher._.then(
      self,
      that
    ));
  }
  static public function provide<I,O,Oi>(self:ConvertDef<I,O>,i:I):Provide<O>{
    return Provide.lift(
      (_:Noise,cont:Terminal<O,Noise>) -> self(i,cont)
    );
  }
  static public function convert<I,O,Oi>(self:ConvertDef<I,O>,that:ConvertDef<O,Oi>):Convert<I,Oi>{
    return Convert.lift(
      Fletcher._.then(
        self,
        that
      )
    );
  }
  static public function first<I,Ii,O>(self:Convert<I,O>):Convert<Couple<I,Ii>,Couple<O,Ii>>{
    return Convert.lift(Fletcher._.first(self));
  }
}