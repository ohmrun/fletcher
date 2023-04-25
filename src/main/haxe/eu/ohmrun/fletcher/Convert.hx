package eu.ohmrun.fletcher;

typedef ConvertDef<I,O> = FletcherDef<I,O,Noise>;

enum ConvertArgSum<P,R>{
  ConvertArgFun1R(fn:P->R);
  ConvertArgLift(x:FletcherDef<P,R,Noise>);
}
abstract ConvertArg<P,R>(ConvertArgSum<P,R>) from ConvertArgSum<P,R> to ConvertArgSum<P,R>{
  public function new(self) this = self;
  @:noUsing static public function lift<P,R>(self:ConvertArgSum<P,R>):ConvertArg<P,R> return new ConvertArg(self);

  @:from static public function fromArgFun1R<P,R>(self:P->R){
    return lift(ConvertArgFun1R(self));
  }
  @:from static public function fromArgLift<P,R>(self:FletcherDef<P,R,Noise>):ConvertArg<P,R>{
    return lift(ConvertArgLift(self));
  }
  public function prj():ConvertArgSum<P,R> return this;
  private var self(get,never):ConvertArg<P,R>;
  private function get_self():ConvertArg<P,R> return lift(this);
  @:to public function bump(){
    return switch(this){
      case ConvertArgFun1R(fn)  : Convert.fromFun1R(fn);
      case ConvertArgLift(x)    : Convert.lift(x);
    }
  }
}
/**
  An Fletcher with no fail case
**/
@:transitive
@:using(eu.ohmrun.fletcher.Convert.ConvertLift)
abstract Convert<I,O>(ConvertDef<I,O>) from ConvertDef<I,O> to ConvertDef<I,O>{
  static public var _(default,never) = ConvertLift;
  public inline function new(self) this = self;
  @:noUsing static public inline function lift<I,O>(self:ConvertDef<I,O>):Convert<I,O> return new Convert(self);
  @:noUsing static public inline function unit<I>():Convert<I,I> return lift(Fletcher.Sync((i:I)->i));

  @:noUsing static public function fromFun1Provide<I,O>(self:I->Provide<O>):Convert<I,O>{
    return lift(
      Fletcher.Anon((i:I,cont:Terminal<O,Noise>) -> cont.receive(self(i).forward(Noise)))
    );
  }
  @:noUsing static public function fromConvertProvide<P,R>(self:Convert<P,Provide<R>>):Convert<P,R>{
    return lift(
      Fletcher.Anon(
        (p:P,cont) -> cont.receive(self.forward(p).flat_fold(
          (ok:Provide<R>)   -> ok.forward(Noise),
          (er)              -> Receiver.error(er)
      )))
    );
  }
  
  @:to public inline function toFletcher():Fletcher<I,O,Noise>{
    return this;
  }
  private var self(get,never):Convert<I,O>;
  private function get_self():Convert<I,O> return lift(this);

  @:from static public function Fun<I,O>(fn:I->O):Convert<I,O>{
    return fromFun1R(fn);
  }
  @:from static inline public function fromFun1R<I,O>(fn:I->O):Convert<I,O>{
    return lift(Fletcher.fromFun1R(fn));
  }
  @:from static inline public function fromUnary<I,O>(fn:Unary<I,O>):Convert<I,O>{
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
  static public function toModulate<I,O,E>(self:Convert<I,O>):Modulate<I,O,E>{
    return Modulate.lift(
      Fletcher.Anon((p:Upshot<I,E>,cont:Waypoint<O,E>) -> p.fold(
        ok -> cont.receive(self.forward(ok).map(__.accept)),
        no -> cont.receive(cont.value(__.reject(no)))
      ))
    );
  }
  static public function then<I,O,Oi>(self:ConvertDef<I,O>,that:Convert<O,Oi>):Convert<I,Oi>{
    //__.log().debug(_ -> _.pure(pos));
    return Convert.lift(Fletcher._.then(
      self,
      that
    ));
  }
  static public function provide<I,O,Oi>(self:ConvertDef<I,O>,i:I):Provide<O>{
    return Provide.lift(
      Fletcher.Anon((_:Noise,cont:Terminal<O,Noise>) -> self.defer(i,cont))
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
  static public function flat_map<P,Ri,Rii>(self:Convert<P,Ri>,fn:Ri->Provide<Rii>):Convert<P,Rii>{
    return Fletcher.Then(
      self,
      Fletcher.Anon(
        (rI:Ri,cont:Terminal<Rii,Noise>) -> {
          return fn(rI).defer(rI,cont);
        }
      )
    );
  }
}