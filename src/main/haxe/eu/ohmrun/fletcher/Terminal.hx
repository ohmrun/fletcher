package eu.ohmrun.fletcher;

typedef TerminalAbs<R,E>    = Settle<TerminalInput<R,E>>;
typedef TerminalApi<R,E>    = SettleApi<TerminalInput<R,E>>;
typedef TerminalCls<R,E>    = SettleCls<TerminalInput<R,E>>;

@:using(eu.ohmrun.fletcher.Terminal.TerminalLift)
@:forward abstract Terminal<R,E>(TerminalApi<R,E>) from TerminalApi<R,E> to TerminalApi<R,E>{
  @:noUsing static public inline function unit<R,E>():Terminal<R,E>{
    return lift(
      Cont.AnonAnon((fn:TerminalInput<R,E> -> Work) -> {
        return fn(TerminalInput.unit());
      })
    );
  }
  static public inline function lift<R,E>(self:TerminalApi<R,E>):Terminal<R,E>{
    return new Terminal(self);
  }       
  public inline function new(self:TerminalApi<R,E>){
    this = self;
  }
  @:to public function toSettle():Settle<TerminalInput<R,E>>{
    return Settle.lift(this.toCont());
  }
  public inline function toTerminal():Terminal<R,E> return this;
  public inline function prj():TerminalApi<R,E> return this;
}

class TerminalLift{
  static function lift<R,E>(self:TerminalApi<R,E>):Terminal<R,E>{
    return Terminal.lift(self);
  }
  static public inline function error<R,E>(self:Terminal<R,E>,e:Defect<E>):Receiver<R,E>{
    return issue(self,__.failure(e));
  }
  static public inline function value<R,E>(self:Terminal<R,E>,r:R):Receiver<R,E>{
    return issue(self,__.success(r));
  }
  static public inline function issue<R,E>(self:Terminal<R,E>,value:ArwOut<R,E>):Receiver<R,E>{
    return Receiver.lift(Settle._.map(
      self,
      (trg:TerminalInput<R,E>) -> {
        trg.trigger(value);
        return trg.asFuture();
      }
    ).prj());
  } 
  static public inline function later<R,E>(self:Terminal<R,E>,ft:Future<Outcome<R,Defect<E>>>,?pos:Pos):Receiver<R,E>{
    return Receiver.lift(
      Cont.Anon((r_ipt:ReceiverSinkApi<R,E>) -> {
        var next = Future.trigger();
        var fst = self.apply(
          Apply.Anon((t_ipt:TerminalInput<R,E>) -> {
            ft.handle(
              res -> {
                t_ipt.trigger(res);
                next.trigger(res);
              }
            );
            return Work.unit();
          })
        );
        var snd = r_ipt.apply(next.asFuture());
        return fst.seq(snd);
      })
    );
  }
  // static public function joint<R,E,RR,EE>(self:Receiver<R,E>):Terminal<RR,EE>{
  //   return Terminal.lift(Continuation.lift(Terminal.unit().prj()).zip_with(self.prj(),(lhs,rhs) -> lhs).asFunction());
  // }
  static public function tap<P,E>(self:TerminalApi<P,E>,fn:ArwOut<P,E>->Void):Terminal<P,E>{
    return lift(Cont.AnonAnon(
      (cont:TerminalInput<P,E>->Work) -> Terminal.lift(self).apply(
        Apply.Anon(
          (p:TerminalInput<P,E>) -> {
            p.asFuture().handle(fn);
            return cont(p);
          }
        )
      )
    ));
  }
  static public inline function mod<P,E>(self:TerminalApi<P,E>,g:Work->Work):Terminal<P,E>{
    return lift(
      Cont.Mod(self,g)
    );
  }
  static public inline function receive<P,E>(self:TerminalApi<P,E>,receiver:Receiver<P,E>):Work{
    return receiver.apply(
      Apply.Anon((oc:ReceiverInput<P,E>) -> {
        return Terminal.lift(self).apply(
          Apply.Anon((ip:TerminalInput<P,E>) -> {
            oc.handle(
              (out) -> {
                ip.trigger(out);
              }
            );
            return Work.unit();
          })
        );
      })
    );
  }
}