package eu.ohmrun.fletcher;

enum ScenarioArgSum<P,Ri,Rii,E>{
  //ScenarioArgP(r:P);
  //ScenarioFunEquityProvide(fn:Equity<P,Ri,Rii,E> -> Provide<Equity<P,Ri,Rii,E>>);
}
abstract ScenarioArg<P,Ri,Rii,E>(ScenarioArgSum<P,Ri,Rii,E>) from ScenarioArgSum<P,Ri,Rii,E> to ScenarioArgSum<P,Ri,Rii,E>{
  public function new(self) this = self;
  static public function lift<P,Ri,Rii,E>(self:ScenarioArgSum<P,Ri,Rii,E>):ScenarioArg<P,Ri,Rii,E> return new ScenarioArg(self);

  public function prj():ScenarioArgSum<P,Ri,Rii,E> return this;
  private var self(get,never):ScenarioArg<P,Ri,Rii,E>;
  private function get_self():ScenarioArg<P,Ri,Rii,E> return lift(this);

  // @:to public function toFletcher():ScenarioDef<P,Ri,Rii,E>{
  //   return switch(this){
  //     case ScenarioArgP(p) : Fletcher.pure(Equity.make(p,null,null));
  //   }
  // }
}
typedef ScenarioDef<P,Ri,Rii,E> = FletcherApi<Equity<P,Ri,E>,Equity<P,Rii,E>,Noise>;

@:using(eu.ohmrun.fletcher.Scenario.ScenarioLift)
abstract Scenario<P,Ri,Rii,E>(ScenarioDef<P,Ri,Rii,E>) from ScenarioDef<P,Ri,Rii,E> to ScenarioDef<P,Ri,Rii,E>{
  static public var _(default,never) = ScenarioLift;
  public function new(self) this = self;
  static public function lift<P,Ri,Rii,E>(self:ScenarioDef<P,Ri,Rii,E>):Scenario<P,Ri,Rii,E> return new Scenario(self);

  // @:from static public function bump<P,Ri,Rii,E>(self:ScenarioArg<P,Ri,Rii,E>):Scenario<P,Ri,Rii,E>{
  //   return lift(self.toFletcher());
  // } 
  public function prj():ScenarioDef<P,Ri,Rii,E> return this;
  private var self(get,never):Scenario<P,Ri,Rii,E>;
  private function get_self():Scenario<P,Ri,Rii,E> return lift(this);
}
class ScenarioLift{
  // static public function attempt<P,Ri,Rii,Rii,Riii,E>(self:Scenario<P,Ri,Rii,E>,that:Attempt<Rii,Riii,E>):Scenario<P,Ri,Rii,E>{
  //   return self.then(
  //     Fletcher.Anon(
  //       function(r:Equity<P,Rii,E>,cont:Terminal<Equity<P,Riii,E>,Noise>){
  //         return cont.receive(
            
  //         );
  //       }
  //     ) 
  //   );
  // }
}