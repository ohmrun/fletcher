package eu.ohmrun;

interface FletcherApi<P,Pi,E> {
  public function defer(p:P,cont:Terminal<Pi,E>):Work;
}
typedef FletcherDef<P,Pi,E> = P -> Terminal<Pi,E> -> Work;

@:using(eu.ohmrun.Fletcher.FletcherLift)
@:callable abstract Fletcher<P,Pi,E>(FletcherDef<P,Pi,E>) from FletcherDef<P,Pi,E> to FletcherDef<P,Pi,E>{
  static public var _(default,never) = FletcherLift;
  public function new(self) this = self;
  static public function lift<P,Pi,E>(self:FletcherDef<P,Pi,E>):Fletcher<P,Pi,E> return new Fletcher(self);

  public function prj():FletcherDef<P,Pi,E> return this;
  private var self(get,never):Fletcher<P,Pi,E>;
  private function get_self():Fletcher<P,Pi,E> return lift(this);

  @:from static public function fromApi<P,Pi,E>(self:FletcherApi<P,Pi,E>){
    return lift(self.defer); 
  }
  static public function unit<P,E>():Fletcher<P,P,E>{
    return Sync(x -> x);
  }
  static public function constant<P,R,E>(self:ArwOut<R,E>):Fletcher<P,R,E>{
    return lift(
      (_:P,cont:Terminal<R,E>) -> cont.issue(self).serve()
    );
  }
  static public function pure<P,R,E>(self:R):Fletcher<P,R,E>{
    return constant(__.success(self));
  }
  static public inline function fromFun1R<P,R,E>(self:P->R):Fletcher<P,R,E>{
    return Sync(self);
  }
  static public inline function fromFunXR<R,E>(self:Void->R):Fletcher<Noise,R,E>{
    return Sync((_:Noise) -> self());
  }
  static public function forward<P,Pi,E>(f:P -> Terminal<Pi,E> -> Work,p:P):Receiver<Pi,E>{
    return Receiver.lift(
      function(k:ReceiverSink<Pi,E>){
        var ft  = Future.trigger();
        var fst = f(
          p,
          Terminal.lift(
            (t_sink:TerminalSink<Pi,E>) -> {
              return t_sink(ft);
            }
          )
        );
        var snd = k(ft.asFuture());
        return fst.seq(snd);
      }
    );
  }
  static public inline function Sync<P,R,E>(fn:P->R):Fletcher<P,R,E>{
    return lift(
      (p:P,cont:Terminal<R,E>) -> {
        var res   = fn(p);
        trace(res);
        var resI  = cont.value(res).serve();
        return resI;
      }
    );
  }

  static public function FlatMap<P,R,Ri,E>(self:Fletcher<P,R,E>,fn:R->Fletcher<P,Ri,E>):Fletcher<P,Ri,E>{
    return lift(
      (p:P,cont:Terminal<Ri,E>) -> cont.receive(self.forward(p).flat_fold(
        (ok:R)  -> fn(ok).forward(p),
        no      -> Receiver.error(no)
      ))
    );
  }
  static public function Anon<P,R,E>(self:FletcherDef<P,R,E>):Fletcher<P,R,E>{
    return lift(self);
  }
  static public inline function Then<P,Ri,Rii,E>(self:Fletcher<P,Ri,E>,that:Fletcher<Ri,Rii,E>):Fletcher<P,Rii,E>{
    return _.then(self,that);
  }
  static public inline function Delay<I,E>(ms):Fletcher<I,I,E>{
    return lift(
      (ipt:I,cont:Terminal<I,E>) -> {
        var bang = Work.wait();
        haxe.Timer.delay(
          () -> {
            bang.fill(cont.value(ipt).serve().toCycle());
          },
          ms
        );
        return bang;
      }
    );
  }
}
class FletcherLift{
  static public function lift<P,R,E>(self:FletcherDef<P,R,E>):Fletcher<P,R,E>{
    return Fletcher.lift(self);
  }
  static public function environment<P,Pi,E>(self:Fletcher<P,Pi,E>,p:P,success:Pi->Void,?failure:Defect<E>->Void):Fiber{
    return Fiber.lift(
    (_:Noise,cont:Terminal<Noise,Noise>) -> {
      return self(
        p,
        Terminal.lift(
          (fn:TerminalSink<Pi,E>) -> {
            return Work.unit();
          }
        )
      ).seq(cont.apply(
        (fn) -> {
          fn.trigger(__.success(Noise));
          return Work.unit();
        }
      ));
    });
  }
  static public function fudge<P,R,E>(self:Fletcher<P,R,E>,p:P):R{
    var val = null;
    environment(
      self,
      p,
      (ok) -> val = ok,
      (no) -> __.crack(no)
    ).crunch();
    return val;
  }
  static public function then<Pi,Ri,Rii,E>(self:Fletcher<Pi,Ri,E>,that:Fletcher<Ri,Rii,E>):Fletcher<Pi,Rii,E>{
    return Fletcher.lift(
      (pI:Pi,cont:Terminal<Rii,E>) -> {
        trace(pI);
        var a = self.forward(pI);
        trace('forwarded');
        return a.flat_fold(
          ok -> that.forward(ok),
          no -> Receiver.error(no)
        ).serve();
      }  
    );
  }
  static public function pair<Pi,Ri,Pii,Rii,E>(self:FletcherDef<Pi,Ri,E>,that:Fletcher<Pii,Rii,E>):Fletcher<Couple<Pi,Pii>,Couple<Ri,Rii>,E>{
    return Fletcher.lift((p:Couple<Pi,Pii>,cont:Terminal<Couple<Ri,Rii>,E>) -> {
      final lhs = self.forward(p.fst());
      final rhs = that.forward(p.snd());
      return lhs.zip(rhs).serve();
    });
  }
  static public function split<Pi,Ri,Rii,E>(self:FletcherDef<Pi,Ri,E>,that:FletcherDef<Pi,Rii,E>):Fletcher<Pi,Couple<Ri,Rii>,E>{
    return lift(
      (pi:Pi,cont) -> pair(self,that)(__.couple(pi,pi),cont)
    );
  }
  static public function first<Pi,Pii,Ri,E>(self:FletcherDef<Pi,Ri,E>):Fletcher<Couple<Pi,Pii>,Couple<Ri,Pii>,E>{
    return pair(self,Fletcher.unit()); 
  }
  static public function pinch<P,Ri,Rii,E>(self:FletcherDef<P,Ri,E>,that:Fletcher<P,Rii,E>):Fletcher<P,Couple<Ri,Rii>,E>{
    return lift((p:P,cont:Terminal<Couple<Ri,Rii>,E>) -> cont.receive(
      self.forward(p).zip(that.forward(p))
    ));
  }
  static public function map<P,Ri,Rii,E>(self:FletcherDef<P,Ri,E>,that:Ri->Rii):Fletcher<P,Rii,E>{
    return lift(
      (p:P,cont:Terminal<Rii,E>) -> cont.receive(
        self.forward(p).map(that)
      )
    );
  }
  static public function mapi<P,Pi,R,E>(self:FletcherDef<Pi,R,E>,that:P->Pi):Fletcher<P,R,E>{
    return lift(
      (p:P,cont:Terminal<R,E>) -> self(that(p),cont)
    );
  }
  static public function joint<I,Oi,Oii,E>(lhs:FletcherDef<I,Oi,E>,rhs:Fletcher<Oi,Oii,E>):Fletcher<I,Couple<Oi,Oii>,E>{
    return then(lhs,Fletcher.unit().split(rhs));
  }
  static public function bound<P,Oi,Oii,E>(self:FletcherDef<P,Oi,E>,that:Fletcher<Couple<P,Oi>,Oii,E>):Fletcher<P,Oii,E>{
    return joint(Fletcher.unit(),self).then(that);
  }
  static public function broach<Oi,Oii,E>(self:FletcherDef<Oi,Oii,E>):Fletcher<Oi,Couple<Oi,Oii>,E>{
    return bound(self,Fletcher.Sync(__.decouple(__.couple)));
  }
}

typedef TerminalSinkDef<R,E>    = eu.ohmrun.fletcher.TerminalSink.TerminalSinkDef<R,E>;
typedef TerminalSink<R,E>       = eu.ohmrun.fletcher.TerminalSink<R,E>;
typedef ReceiverDef<R,E>        = eu.ohmrun.fletcher.Receiver.ReceiverDef<R,E>;
typedef Receiver<R,E>           = eu.ohmrun.fletcher.Receiver<R,E>;
typedef TerminalDef<R,E>        = eu.ohmrun.fletcher.Terminal.TerminalDef<R,E>;
typedef Terminal<R,E>           = eu.ohmrun.fletcher.Terminal<R,E>;
typedef Waypoint<R,E>           = Terminal<Res<R,E>,Noise>;

typedef Fiber                   = eu.ohmrun.fletcher.Fiber;
typedef FiberDef                = eu.ohmrun.fletcher.Fiber.FiberDef;

typedef Convert<I,O>            = eu.ohmrun.fletcher.Convert<I,O>;
typedef ConvertDef<I,O>         = eu.ohmrun.fletcher.Convert.ConvertDef<I,O>;

typedef Provide<O>              = eu.ohmrun.fletcher.Provide<O>;
typedef ProvideDef<O>           = eu.ohmrun.fletcher.Provide.ProvideDef<O>;

typedef CascadeDef<I,O,E>       = eu.ohmrun.fletcher.Cascade.CascadeDef<I,O,E>;
typedef Cascade<I,O,E>          = eu.ohmrun.fletcher.Cascade<I,O,E>;

typedef ArrangeDef<I,S,O,E>     = eu.ohmrun.fletcher.Arrange.ArrangeDef<I,S,O,E>;
typedef Arrange<I,S,O,E>        = eu.ohmrun.fletcher.Arrange<I,S,O,E>;

typedef ReframeDef<I,O,E>       = eu.ohmrun.fletcher.Reframe.ReframeDef<I,O,E>;
typedef Reframe<I,O,E>          = eu.ohmrun.fletcher.Reframe<I,O,E>;

typedef AttemptDef<I,O,E>       = eu.ohmrun.fletcher.Attempt.AttemptDef<I,O,E>;
typedef Attempt<I,O,E>          = eu.ohmrun.fletcher.Attempt<I,O,E>;

typedef CommandDef<I,E>         = eu.ohmrun.fletcher.Command.CommandDef<I,E>;
typedef Command<I,E>            = eu.ohmrun.fletcher.Command<I,E>;

typedef DiffuseDef<I,O,E>       = eu.ohmrun.fletcher.Diffuse.DiffuseDef<I,O,E>;
typedef Diffuse<I,O,E>          = eu.ohmrun.fletcher.Diffuse<I,O,E>;

typedef ExecuteDef<E>           = eu.ohmrun.fletcher.Execute.ExecuteDef<E>;
typedef Execute<E>              = eu.ohmrun.fletcher.Execute<E>;

typedef PerformDef              = eu.ohmrun.fletcher.Perform.PerformDef;
typedef Perform                 = eu.ohmrun.fletcher.Perform;

typedef ProduceDef<O,E>         = eu.ohmrun.fletcher.Produce.ProduceDef<O,E>;
typedef Produce<O,E>            = eu.ohmrun.fletcher.Produce<O,E>;

typedef ProposeDef<O,E>         = eu.ohmrun.fletcher.Propose.ProposeDef<O,E>;
typedef Propose<O,E>            = eu.ohmrun.fletcher.Propose<O,E>;

typedef RecoverDef<I,E>         = eu.ohmrun.fletcher.Recover.RecoverDef<I,E>;
typedef Recover<I,E>            = eu.ohmrun.fletcher.Recover<I,E>;

typedef RectifyDef<I,O,E>       = eu.ohmrun.fletcher.Rectify.RectifyDef<I,O,E>;
typedef Rectify<I,O,E>          = eu.ohmrun.fletcher.Rectify<I,O,E>;

typedef ResolveDef<I,E>         = eu.ohmrun.fletcher.Resolve.ResolveDef<I,E>;
typedef Resolve<I,E>            = eu.ohmrun.fletcher.Resolve<I,E>;

typedef TerminalInputDef<R,E>   = eu.ohmrun.fletcher.TerminalInput.TerminalInputDef<R,E>;
typedef TerminalInput<R,E>      = eu.ohmrun.fletcher.TerminalInput<R,E>;

typedef ReceiverSink<R,E>       = eu.ohmrun.fletcher.ReceiverSink<R,E>;