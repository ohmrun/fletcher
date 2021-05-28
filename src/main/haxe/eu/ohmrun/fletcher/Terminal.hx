package eu.ohmrun.fletcher;

typedef TerminalDef<R,E>    = Ref<ContinuationDef<Work,ArwOut<R,E>>>;

@:using(eu.ohmrun.fletcher.Terminal.TerminalLift)
@:forward(get_value)abstract Terminal<R,E>(TerminalDef<R,E>) from TerminalDef<R,E> to TerminalDef<R,E>{
  // @:noUsing static public function unit<R,E>():Terminal<R,E>{
  //   return lift(
  //     (fn:ArwOut<R,E> -> Work) -> return Work.unit() 
  //   );
  // }
  static public function lift<R,E>(self:TerminalDef<R,E>):Terminal<R,E>{
    return new Terminal(self);
  }       
  public function new(self:TerminalDef<R,E>){
    this = self;
  }
  public function reply():Work{
    return @:privateAccess this.get_value()(TerminalSink.unit());
  }
  public function apply(fn:ArwOut<R,E>->Work):Work{
    return this.value(fn);
  }
  public function replace(self:Receiver<R,E>){
    trace('replace');
    @:privateAccess this.set_value(
      (fn:TerminalSink<R,E>) -> {
        trace("CALLED");
        @:privateAccess final thiz = this.get_value();
        var a = thiz(fn);
        var b = self.apply(fn);
        return a.seq(b);
        //Terminal.lift(self).get_value()
      }
    );
  }
  public function toTerminal():Terminal<R,E> return this;
  public function prj():TerminalDef<R,E> return this;
}

class TerminalLift{
  static public function error<R,E>(self:Terminal<R,E>,e:Defect<E>):Receiver<R,E>{
    return issue(self,__.failure(e));
  }
  static public function value<R,E>(self:Terminal<R,E>,r:R):Receiver<R,E>{
    return issue(self,__.success(r));
  }
  static public function issue<R,E>(self:Terminal<R,E>,value:ArwOut<R,E>):Receiver<R,E>{
    trace("issue");
    var done = false;
    var next = Receiver.lift(
      function(fn:ArwOut<R,E>->Work):Work{
        trace('using issue: $value');
        return fn(value);
      }
    );
    self.replace(next);
    trace('replaced');
    return next;
  } 
  static public function later<R,E>(self:Terminal<R,E>,ft:Future<Outcome<R,Defect<E>>>,?pos:Pos):Receiver<R,E>{
    return Receiver.lift((fn:TerminalSink<R,E>) -> {
      return Work.lift(Some(ft.flatMap(
        (outcome) -> fn(outcome).prj().fold(
          ok -> ok,
          () -> Future.irreversible(cb -> cb(Cycle.ZERO))
        )
      ))).seq(
        self.apply(fn)
      );
    });
  }
  // static public function joint<R,E,RR,EE>(self:Receiver<R,E>):Terminal<RR,EE>{
  //   return Terminal.lift(Continuation.lift(Terminal.unit().prj()).zip_with(self.prj(),(lhs,rhs) -> lhs).asFunction());
  // }
  static public function apply<P,E>(self:TerminalDef<P,E>,fn:ArwOut<P,E>->Work):Work{
    return self.value(fn);
  }
  static public function tap<P,E>(self:TerminalDef<P,E>,fn:ArwOut<P,E>->Void):Terminal<P,E>{
    return (cont:ArwOut<P,E>->Work) -> Terminal.lift(self).apply(
      (p:ArwOut<P,E>) -> {
        trace(p);
        fn(p);
        return cont(p);
      }
    );
  }
  static public function mod<P,E>(self:TerminalDef<P,E>,g:Work->Work):Terminal<P,E>{
    return (f:ArwOut<P,E>->Work) -> {
      return g(Terminal.lift(self).apply(f));
    };
  }
  static public function acc<P,E>(self:TerminalDef<P,E>,fn:ArwOut<P,E>->Work):Terminal<P,E>{
    return (f:ArwOut<P,E>->Work) -> {
      trace('call a');
      var a = Terminal.lift(self).apply(
        (res) -> {
          trace(res);
          return fn(res);
        }
      );
      trace('call b');
      var b = Terminal.lift(self).apply(
        res -> {
          trace(res);
          return f(res);
        }
      );
      return a.seq(b);
    }; 
  }
  // static public function defer<P,Pi,E,EE>(self:TerminalDef<P,E>,that:Receiver<Pi,EE>):Terminal<P,E>{
  //   return Receiver.lift((f:ArwOut<P,E>->Work) -> {
  //     var lhs = that.reply();
  //     trace("lhs called"); 
  //     return lhs.seq(Terminal.lift(self).apply(f));
  //   });
  // }
  static public function joint<P,Pi,E,EE>(self:TerminalDef<P,E>,that:Terminal<Pi,EE>->Receiver<Pi,EE>):Terminal<Pi,EE>{
    var done = false;
    var next = null;
        next = (fn:TerminalSink<Pi,EE>) -> {
          return switch(done){
            case false : 
              done = true;
              that(next).reply().seq(Receiver.lift(self).reply());
            case true  : 
              Work.unit();
          }
        };
    return next;
  }
  static public function receive<P,E>(self:TerminalDef<P,E>,receiver:Receiver<P,E>):Work{
    return receiver.apply(
      (oc:ArwOut<P,E>) -> {
        trace(oc);
        Terminal.lift(self).reply();
      }
    );
  }
}