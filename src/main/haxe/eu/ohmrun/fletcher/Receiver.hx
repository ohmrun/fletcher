package eu.ohmrun.fletcher;

typedef ReceiverDef<R,E> = TerminalDef<R,E>;

@:using(eu.ohmrun.fletcher.Receiver.ReceiverLift)
abstract Receiver<R,E>(ReceiverDef<R,E>) to ReceiverDef<R,E>{
  static public var _(default,never) = ReceiverLift;
  public function reply():Work{
    return this(TerminalSinks.unit());
  }
  public function apply(fn){
    return this(fn);
  }
  static inline public function lift<R,E>(self:ReceiverDef<R,E>) return new Receiver(self);

  private inline function new(self:ReceiverDef<R,E>) this = self;

  @:noUsing static public function issue<R,E>(outcome:Outcome<R,Defect<E>>,?pos:Pos):Receiver<R,E>{
    return Receiver.lift((fn:ArwOut<R,E>->Work) -> {
      return fn(outcome);
    });
  }
  @:noUsing static public function value<R,E>(r:R,?pos:Pos):Receiver<R,E>{
    return issue(__.success(r));
  }
  @:noUsing static public function error<R,E>(err:Defect<E>,?pos:Pos):Receiver<R,E>{
    return issue(__.failure(err));
  }
  @:noUsing static public function later<R,E>(ft:Future<Outcome<R,Defect<E>>>,?pos:Pos):Receiver<R,E>{
    return Receiver.lift((fn:TerminalSink<R,E>) -> {
      return Work.lift(Some(ft.flatMap(
        (outcome) -> fn(outcome).prj().fold(
          ok -> ok,
          () -> Future.irreversible(cb -> cb(Cycle.ZERO))
        )
      )));
    });
  }
  public inline function serve():Work{
    return reply();
  }
  public function toString(){
    return 'Receiver($this)';
  }
  public function prj():TerminalDef<R,E>{
    return this;
  }
}
class ReceiverLift{
  static public function defer<P,Pi,E,EE>(self:ReceiverDef<P,E>,that:Receiver<Pi,EE>):Receiver<P,E>{
    return Receiver.lift((f:ArwOut<P,E>->Work) -> {
      var lhs = that.reply();
      trace("lhs called"); 
      return lhs.seq(Terminal.lift(self).apply(f));
    });
  }
  // static public function joint<P,Pi,E,EE>(self:ReceiverDef<P,E>,that:Terminal<Pi,EE>->Receiver<Pi,EE>):Terminal<Pi,EE>{
  //   var done = false;
  //   var next = null;
  //       next = (fn:TerminalSink<Pi,EE>) -> {
  //         return switch(done){
  //           case false : 
  //             done = true;
  //             that(next).reply().seq(Receiver.lift(self).reply());
  //           case true  : 
  //             Work.unit();
  //         }
  //       };
  //   return next;
  // }
  static public function flat_fold<P,Pi,E>(self:ReceiverDef<P,E>,fn:ArwOut<P,E>->Receiver<Pi,E>):Receiver<Pi,E>{
    return Receiver.lift(Continuation.lift(self).flat_map(
      (x) -> Continuation.lift(fn(x))
    ));
  }
  static public function map<P,Pi,E>(self:ReceiverDef<P,E>,fn:P->Pi):Receiver<Pi,E>{
    return Receiver.lift((cont:ArwOut<Pi,E>->Work) -> self(
      (p:ArwOut<P,E>) -> cont(p.map(fn))
    ));
  }
  static public function fold_map<P,Pi,E,EE>(self:ReceiverDef<P,E>,ok:P->ArwOut<Pi,EE>,no:Defect<E>->ArwOut<Pi,EE>):Receiver<Pi,EE>{
    return Receiver.lift((cont:ArwOut<Pi,EE>->Work) -> self(
      (p:ArwOut<P,E>) -> cont(
        p.fold(
          ok,
          no
        )
      )
    ));
  }
  static public function mod<P,E>(self:ReceiverDef<P,E>,g:Work->Work):Receiver<P,E>{
    return Receiver.lift((f:ArwOut<P,E>->Work) -> {
      return g(self(f));
    });
  }
  static public function zip<Pi,Pii,E>(self:ReceiverDef<Pi,E>,that:Receiver<Pii,E>):Receiver<Couple<Pi,Pii>,E>{
    return Receiver.lift(
      (f:ArwOut<Couple<Pi,Pii>,E> -> Work) -> {
        var lhs        = null;
        var rhs        = null;
        var work_left  = Receiver.lift(self).apply(
          (ocI)   -> {
            lhs = ocI;
            return Work.unit();
          }
        );
        var work_right = that.apply(
          (ocII)  -> {
            rhs = ocII;
            return Work.unit();
          }
        );
        return work_left.par(work_right).seq(
          Future.irreversible(
            (cb:Work->Void) -> {
              var ipt        = lhs.zip(rhs);
              var res        = f(ipt);
              cb(res);
            }
          )
        );
      }
    );
  }
}