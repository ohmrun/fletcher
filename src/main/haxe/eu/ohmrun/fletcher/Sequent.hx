package eu.ohmrun.fletcher;

enum SequentArgSum<P,R,E>{
  SequentArgP(r:P);
}
abstract SequentArg<P,R,E>(SequentArgSum<P,R,E>) from SequentArgSum<P,R,E> to SequentArgSum<P,R,E>{
  public function new(self) this = self;
  static public function lift<P,R,E>(self:SequentArgSum<P,R,E>):SequentArg<P,R,E> return new SequentArg(self);

  public function prj():SequentArgSum<P,R,E> return this;
  private var self(get,never):SequentArg<P,R,E>;
  private function get_self():SequentArg<P,R,E> return lift(this);

  @:to public function toFletcher():SequentDef<P,R,E>{
    return switch(this){
      case SequentArgP(p) : Fletcher.pure(Equity.make(p,null,null));
    }
  }
}
typedef SequentDef<P,R,E> = FletcherApi<Equity<P,R,E>,Equity<P,R,E>,Noise>;

@:using(eu.ohmrun.fletcher.Sequent.SequentLift)
abstract Sequent<P,R,E>(SequentDef<P,R,E>) from SequentDef<P,R,E> to SequentDef<P,R,E>{
  static public var _(default,never) = SequentLift;
  public function new(self) this = self;
  static public function lift<P,R,E>(self:SequentDef<P,R,E>):Sequent<P,R,E> return new Sequent(self);

  @:from static public function bump<P,R,E>(self:SequentArg<P,R,E>):Sequent<P,R,E>{
    return lift(self.toFletcher());
  } 
  public function prj():SequentDef<P,R,E> return this;
  private var self(get,never):Sequent<P,R,E>;
  private function get_self():Sequent<P,R,E> return lift(this);
}
class SequentLift{
  static public function provide<P,R,E>(self:SequentDef<P,R,E>,v:Equity<P,R,E>):Provide<Equity<P,R,E>>{
    return Convert.lift(self).provide(v);
  }
}