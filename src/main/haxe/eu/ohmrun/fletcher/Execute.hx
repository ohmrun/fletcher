package eu.ohmrun.fletcher;

typedef ExecuteDef<E>                   = FletcherDef<Noise,Report<E>,Noise>;

@:using(eu.ohmrun.fletcher.Execute.ExecuteLift)
abstract Execute<E>(ExecuteDef<E>) from ExecuteDef<E> to ExecuteDef<E>{
  public inline function new(self) this = self;
  @:noUsing static public inline function lift<E>(self:ExecuteDef<E>):Execute<E> return new Execute(self);
  @:noUsing static public inline function pure<E>(e:Rejection<E>):Execute<E> return lift(Fletcher.pure(Report.pure(e)));
  @:noUsing static public inline function unit<E>():Execute<E> return lift(Fletcher.pure(Report.unit()));

  @:noUsing static public function bind_fold<T,E>(fn:T->Report<E>->Execute<E>,arr:Array<T>):Execute<E>{
    return arr.lfold(
      (next:T,memo:Execute<E>) -> Execute.lift(Provide._.flat_map(
        memo,
        (report) -> lift(fn(next,report))
      )),
      unit()
    );
  }  
  @:noUsing static public function sequence<T,E>(fn:T->Execute<E>,arr:Array<T>):Execute<E>{
    return arr.lfold(
      (next:T,memo:Execute<E>) -> Execute.lift(
        memo.fold_mod(
          (report:Report<E>) -> report.fold(
            (e)-> Execute.pure(e),
            () -> fn(next)
          )
        )
      ),
      unit()
    );
  }
  @:to public function toProvide():Provide<Report<E>>{
    return this;
  }
  @:to public inline function toFletcher():Fletcher<Noise,Report<E>,Noise>{
    return this;
  }
  @:from static public function fromFunXR<E>(fn:Void->Report<E>):Execute<E>{
    return lift(Fletcher.fromFunXR(fn));
  }
  @:from static public function fromThunk<E>(fn:Void->Void):Execute<E>{
    return fromFunXR(()  -> {
      fn();
      return __.report();
    });
  }
  @:from static public function fromFunXExecute<E>(fn:Void->Execute<E>):Execute<E>{
    return fn();
  }
  public function prj():ExecuteDef<E> return this;
  private var self(get,never):Execute<E>;
  private function get_self():Execute<E> return lift(this);

  @:noUsing static public function fromOption<E>(err:Option<Rejection<E>>):Execute<E>{
    return fromFunXR(() -> Report.fromOption(err));
  }
  @:noUsing static public function fromRejection<E>(err:Rejection<E>):Execute<E>{
    return fromFunXR(() -> Report.pure(err));
  }
  public inline function environment(success:Void->Void,failure:Rejection<E>->Void){
    return Fletcher._.environment(
      this,
      Noise,
      (report) -> report.fold(
        failure,
        success
      ),
      __.crack
    );
  }
}
class ExecuteLift{
  static public function errata<E,EE>(self:Execute<E>,fn:Rejection<E>->Rejection<EE>):Execute<EE>{
    return Execute.lift(self.toFletcher().then(
      Fletcher.Sync((report:Report<E>) -> report.errata(fn))
    ));
  }
  static public function errate<E,EE>(self:Execute<E>,fn:E->EE):Execute<EE>{
    return Execute.lift(self.toFletcher().then(
      Fletcher.Sync((report:Report<E>) -> report.errata(
        (e:Rejection<E>) -> e.errate(fn)
      ))
    ));

  }
  static public function deliver<E>(self:Execute<E>,fn:Report<E>->Void):Fiber{
    return Fletcher.Then(
      Fletcher.lift(self),
      Fletcher.Sync(
        (report) -> {
          fn(report);
          return Noise;
        }
      )
    );
  }
  static public function crack<E>(self:Execute<E>):Fiber{
    return deliver(self,
      (report) -> report.fold(
        __.crack,
        () -> {}
      )
    );
  }
  static public function then<E,O>(self:ExecuteDef<E>,that:Fletcher<Report<E>,O,Noise>):Provide<O>{
    return Provide.lift(Fletcher.Then(
      self,
      that
    ));
  }
  static public function execute<E,O>(self:ExecuteDef<E>,next:Execute<E>):Execute<E>{
    return Execute.lift(Fletcher.Then(
      self,
      Fletcher.Anon(
        (ipt:Report<E>,cont:Terminal<Report<E>,Noise>) -> ipt.fold(
          (e) -> cont.value(Report.pure(e)).serve(),
          ()  -> cont.receive(next.forward(Noise))
        )
      )
    ));
  }
  static public function produce<E,O>(self:ExecuteDef<E>,next:Produce<O,E>):Produce<O,E>{
    return Produce.lift(
      Fletcher.Then(
        self,
        Fletcher.Anon(
          (ipt:Report<E>,cont:Waypoint<O,E>) -> ipt.fold(
            (e) -> cont.value(__.reject(e)).serve(),
            ()  -> cont.receive(next.forward(Noise))
          )
        )
      )
    );
  }
  static public function propose<E,O>(self:ExecuteDef<E>,next:Propose<O,E>):Propose<O,E>{
    return Propose.lift(
      Fletcher.Then(
        self,
        Fletcher.Anon(
          (ipt:Report<E>,cont:Terminal<Chunk<O,E>,Noise>) -> ipt.fold(
            (e) -> cont.value(End(e)).serve(),
            ()  -> cont.receive(next.forward(Noise))
          )
        )
      )
    );
  }
  static public function fold_mod<E,EE,O>(self:ExecuteDef<E>,fn:Report<E>->Execute<EE>):Execute<EE>{
    return Execute.lift(
      Fletcher.FlatMap(
        Fletcher.lift(self),
        (report:Report<E>) -> fn(report).toFletcher()
      )
    );
  }
  static public function and<E>(self:Execute<E>,that:Execute<E>):Execute<E>{
    return self.execute(that);
  }
}