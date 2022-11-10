package eu.ohmrun.fletcher.core;

interface ContApi<P,R>{
  public final uuid : String;
  public function toString():String;
  public function apply(p:Apply<P,R>):R;
  public function toCont():Cont<P,R>;
}
abstract class ContCls<P,R> implements ContApi<P,R>{
  public function new(){
    this.uuid = __.uuid("xxxxx");
  }
  abstract public function apply(p:Apply<P,R>):R;
  public inline function toCont():Cont<P,R>{
    return new Cont(this);
  }
  public final uuid : String;
  public function toString():String{
    return Type.getClassName(Type.getClass(this)) + ":" + uuid;
  }
}
@:using(eu.ohmrun.fletcher.core.Cont.ContLift)
@:forward abstract Cont<P,R>(ContApi<P,R>) from ContApi<P,R> to ContApi<P,R>{
  static public var _(default,never) = ContLift;
  public inline function new(self) this = self;
  static public function lift<P,R>(self:ContApi<P,R>):Cont<P,R> return new Cont(self);

  public function prj():ContApi<P,R> return this;
  private var self(get,never):Cont<P,R>;
  private function get_self():Cont<P,R> return lift(this);

  static public inline function Each<P,R>(self:Cont<P,R>,fn:P->Void):Cont<P,R>{
    return lift(new eu.ohmrun.fletcher.core.cont.term.AnonEach(self,fn));
  }
  static public inline function Mod<P,R>(self:Cont<P,R>,fn:R->R):Cont<P,R>{
    return lift(new eu.ohmrun.fletcher.core.cont.term.AnonMod(self,fn));
  }
  static public inline function Anon<P,R>(self:Apply<P,R>->R){
    return lift(new eu.ohmrun.fletcher.core.cont.term.Anon(self));
  }
  static public inline function AnonAnon<P,R>(self:(P->R)->R,?pos:Pos){
    return lift(new eu.ohmrun.fletcher.core.cont.term.AnonAnon(self,pos));
  }
}
class ContLift{
  static public function map<P,Pi,R>(self:ContApi<P,R>,fn:P->Pi):Cont<Pi,R>{
    return new eu.ohmrun.fletcher.core.cont.term.AnonMap(self,fn).toCont();
  }
  static public function flat_map<P,Pi,R>(self:ContApi<P,R>,fn:P -> Cont<Pi,R>):Cont<Pi,R>{
    return new eu.ohmrun.fletcher.core.cont.term.AnonFlatMap(self,fn);
  }
  static public function zip_with<P,Pi,Pii,R>(self:ContApi<P,R>,that:ContApi<Pi,R>,fn:P->Pi->Pii):Cont<Pii,R>{
    return new eu.ohmrun.fletcher.core.cont.term.AnonZipWith(self,that,fn);
  }
  static public function mod<P,R>(self:ContApi<P,R>,fn:R->R):ContApi<P,R>{
    return new eu.ohmrun.fletcher.core.cont.term.AnonMod(self,fn);
  }
}
