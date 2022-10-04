package eu.ohmrun.fletcher.core;

typedef SettleCls<P>      = ContCls<P,Work>; 
typedef SettleApi<P>      = ContApi<P,Work>;

@:using(eu.ohmrun.fletcher.core.Settle.SettleLift)
@:using(eu.ohmrun.fletcher.core.Cont.ContLift)
@:forward abstract Settle<P>(SettleApi<P>) from SettleApi<P> to SettleApi<P>{
  static public var _(default,never) = SettleLift;

  public function new(self) this = self;
  static public inline function lift<P>(self:SettleApi<P>):Settle<P> return new Settle(self);

  public function prj():SettleApi<P> return this;
  private var self(get,never):Settle<P>;
  private function get_self():Settle<P> return lift(this);

  @:noUsing static public function unit<P>():Settle<P>{
    return lift(new eu.ohmrun.fletcher.core.settle.term.Unit());
  }
  @:noUsing static public function pure<P>(v:P):Settle<P>{
    return lift(new eu.ohmrun.fletcher.core.settle.term.Pure(v));
  }
  @:to public function toCont(){
    return this.toCont();
  }
}
class SettleLift{
  static function lift<P>(self:SettleApi<P>):Settle<P>{
    return Settle.lift(self);
  }
  static public function map<Pi,Pii>(self:Settle<Pi>,fn:Pi->Pii):Settle<Pii>{
    return lift(new eu.ohmrun.fletcher.core.cont.term.AnonMap(
      self.toCont(),
      fn
    ));
  }
}