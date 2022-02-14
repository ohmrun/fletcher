package eu.ohmrun.fletcher;

typedef TerminalDef<R,E>    = ContinuationDef<Work,TerminalInput<R,E>>;

@:using(eu.ohmrun.fletcher.Terminal.TerminalLift)
abstract Terminal<R,E>(TerminalDef<R,E>) from TerminalDef<R,E> to TerminalDef<R,E>{
  @:noUsing static public inline function unit<R,E>():Terminal<R,E>{
    return lift(
      (fn:TerminalInput<R,E> -> Work) -> {
        return fn(TerminalInput.unit());
      } 
    );
  }
  static public inline function lift<R,E>(self:TerminalDef<R,E>):Terminal<R,E>{
    return new Terminal(self);
  }       
  public inline function new(self:TerminalDef<R,E>){
    this = self;
  }
  public inline function apply(fn:TerminalInput<R,E>->Work):Work{
    return this(fn);
  }
  public inline function toTerminal():Terminal<R,E> return this;
  public inline function prj():TerminalDef<R,E> return this;
}

class TerminalLift{
  static public inline function error<R,E>(self:Terminal<R,E>,e:Defect<E>):Receiver<R,E>{
    return issue(self,__.failure(e));
  }
  static public inline function value<R,E>(self:Terminal<R,E>,r:R):Receiver<R,E>{
    return issue(self,__.success(r));
  }
  static public inline function issue<R,E>(self:Terminal<R,E>,value:ArwOut<R,E>):Receiver<R,E>{
    return Receiver.lift(Continuation._.map(
      self,
      (trg) -> {
        trg.trigger(value);
        return trg.asFuture();
      }
    ).prj());
  } 
  static public inline function later<R,E>(self:Terminal<R,E>,ft:Future<Outcome<R,Defect<E>>>,?pos:Pos):Receiver<R,E>{
    return Receiver.lift(
      (r_ipt:ReceiverSink<R,E>) -> {
        var next = Future.trigger();
        var fst = self.apply(
          (t_ipt:TerminalInput<R,E>) -> {
            ft.handle(
              res -> {
                t_ipt.trigger(res);
                next.trigger(res);
              }
            );
            return Work.unit();
          }
        );
        var snd = r_ipt(next.asFuture());
        return fst.seq(snd);
      }
    );
  }
  // static public function joint<R,E,RR,EE>(self:Receiver<R,E>):Terminal<RR,EE>{
  //   return Terminal.lift(Continuation.lift(Terminal.unit().prj()).zip_with(self.prj(),(lhs,rhs) -> lhs).asFunction());
  // }
  static public inline function apply<P,E>(self:TerminalDef<P,E>,fn:TerminalInput<P,E>->Work):Work{
    return self(fn);
  }
  static public function tap<P,E>(self:TerminalDef<P,E>,fn:ArwOut<P,E>->Void):Terminal<P,E>{
    return (cont:TerminalInput<P,E>->Work) -> Terminal.lift(self).apply(
      (p:TerminalInput<P,E>) -> {
        p.asFuture().handle(fn);
        return cont(p);
      }
    );
  }
  static public inline function mod<P,E>(self:TerminalDef<P,E>,g:Work->Work):Terminal<P,E>{
    return (f:TerminalInput<P,E>->Work) -> {
      return g(Terminal.lift(self).apply(f));
    };
  }
  static public inline function acc<P,E>(self:TerminalDef<P,E>,fn:TerminalInput<P,E>->Work):Terminal<P,E>{
    return (f:TerminalInput<P,E>->Work) -> {
      __.log().debug('call a');
      var a = Terminal.lift(self).apply(
        (res) -> {
          __.log().debug(_ -> _.pure(res));
          return fn(res);
        }
      );
      __.log().debug('call b');
      var b = Terminal.lift(self).apply(
        res -> {
          __.log().debug(_ -> _.pure(res));
          return f(res);
        }
      );
      return a.seq(b);
    }; 
  }
  // static public function defer<P,Pi,E,EE>(self:TerminalDef<P,E>,that:Receiver<Pi,EE>):Terminal<P,E>{
  //   return Receiver.lift((f:TerminalInput<P,E>->Work) -> {
  //     var lhs = that.reply();
  //     __.log().debug("lhs called"); 
  //     return lhs.seq(Terminal.lift(self).apply(f));
  //   });
  // }
  // static public function joint<P,Pi,E,EE>(self:TerminalDef<P,E>,that:Terminal<Pi,EE>->Receiver<Pi,EE>):Terminal<Pi,EE>{
  //   return Receiver.lift(
  //     (fn:TerminalSink<Pi,EE>) -> {
  //       final next = that(self);
  //     }
  //   );
  // }
  static public inline function receive<P,E>(self:TerminalDef<P,E>,receiver:Receiver<P,E>):Work{
    return receiver.apply(
      (oc:ReceiverInput<P,E>) -> {
        return Terminal.lift(self).apply(
          (ip:TerminalInput<P,E>) -> {
            oc.handle(
              (out) -> {
                ip.trigger(out);
              }
            );
            return Work.unit();
          }
        );
      }
    );
  }
}