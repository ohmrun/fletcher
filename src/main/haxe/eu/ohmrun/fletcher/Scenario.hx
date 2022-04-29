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

  @:to public function toFletcher():Fletcher<Equity<P,Ri,E>,Equity<P,Rii,E>,Noise>{
    return Fletcher.lift(this);
  }
}
class ScenarioLift{
  static public inline function lift<P,Ri,Rii,E>(self:ScenarioDef<P,Ri,Rii,E>):Scenario<P,Ri,Rii,E> return Scenario.lift(self);
  static public function attempt<P,Ri,Rii,Riii,E>(self:ScenarioDef<P,Ri,Rii,E>,that:Attempt<Rii,Riii,E>):Scenario<P,Ri,Riii,E>{
    return lift(Fletcher.Then(self,
      Fletcher.Anon(
        function(r:Equity<P,Rii,E>,cont:Terminal<Equity<P,Riii,E>,Noise>){
          return cont.receive(
            Diffuse._.attempt(Diffuse.unit(),that).map(chk -> r.rebase(chk)).forward(r.toChunk())
          );
        }
      ) 
    ));
  }
  //discharge
  static public function venture<P,Ri,Rii,Riii,E>(self:ScenarioDef<P,Ri,Rii,E>,that:Venture<Rii,Riii,E>){
    return Fletcher.Then(
      self,
      Fletcher.Anon(
        function(r:Equity<P,Rii,E>,cont:Terminal<Equity<P,Riii,E>,Noise>){
          return cont.receive(
            r.has_value().if_else(
              () -> that.map(
                n -> Equity.make(r.asset,n.value,r.error.concat(n.error))
              ).forward(r.value),
              () -> cont.value(r.clear())
            )
          );
        }
      )
    );
  }
  static public function initiate<P,R,E>(self:ScenarioDef<P,Noise,Noise,E>,that:Attempt<P,R,E>):Scenario<P,Noise,R,E>{
    return lift(Fletcher.Then(
      self,
      Fletcher.Anon(
        (r:Equity<P,Noise,E>,cont:Terminal<Equity<P,R,E>,Noise>) -> cont.receive(
          that.toFletcher().map(
            (res:Res<R,E>) -> res.fold(
              ok -> r.rebase(Val(ok)),
              no -> r.rebase(End(no))
            ) 
          ).forward(r.asset)
        )
      )
    ));
  }
  static public function errate<P,Ri,Rii,E,EE>(self:ScenarioDef<P,Ri,Rii,E>,fn:E->EE):Scenario<P,Ri,Rii,EE>{
    return lift(
      Fletcher.Anon(
        (equity:Equity<P,Ri,EE>,cont:Terminal<Equity<P,Rii,EE>,Noise>) -> {
          return cont.receive(
            equity.has_value().if_else(
              () -> self.forward(equity.defuse()).map(
                x -> x.errate(fn).refuse(equity.error)//TODO order?
              ),
              () -> cont.value(equity.clear())
            )
          );
        }
      )     
    );
  }
}