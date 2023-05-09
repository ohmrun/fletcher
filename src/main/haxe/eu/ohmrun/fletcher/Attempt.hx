package eu.ohmrun.fletcher;
  
enum AttemptArgSum<P,R,E>{
  AttemptArgPure(r:R);
  AttemptArgUpshot(res:Upshot<R,E>);
  AttemptArgFun1Upshot(fn:P->Upshot<R,E>);
  AttemptArgFun1Produce(fn:P->Produce<R,E>);
  AttemptArgUnary1Produce(fn:Unary<P,Produce<R,E>>);
  AttemptArgFun1Provide(fn:P->Provide<R>);
}
abstract AttemptArg<I,O,E>(AttemptArgSum<I,O,E>) from AttemptArgSum<I,O,E> to AttemptArgSum<I,O,E>{
  public function new(self) this = self;
  static public function lift<I,O,E>(self:AttemptArgSum<I,O,E>):AttemptArg<I,O,E> return new AttemptArg(self);

  public function prj():AttemptArgSum<I,O,E> return this;
  private var self(get,never):AttemptArg<I,O,E>;
  private function get_self():AttemptArg<I,O,E> return lift(this);

  @:from static public function fromArgFun1Provide<P,R,E>(fn:P->Provide<R>):AttemptArg<P,R,E>{
    return AttemptArgFun1Provide(fn);
  }
  @:from static public function fromArgUnary1Produce<P,R,E>(fn:Unary<P,Produce<R,E>>):AttemptArg<P,R,E>{
    return AttemptArgUnary1Produce(fn);
  }
  @:from static public function fromArgFun1Produce<P,R,E>(fn:P->Produce<R,E>):AttemptArg<P,R,E>{
    return AttemptArgFun1Produce(fn);
  }
  @:from static public function fromArgFun1Upshot<P,R,E>(fn:P->Upshot<R,E>):AttemptArg<P,R,E>{
    return AttemptArgFun1Upshot(fn);
  }
  @:from static public function fromArgUpshot<P,R,E>(fn:Upshot<R,E>):AttemptArg<P,R,E>{
    return AttemptArgUpshot(fn);
  }
  @:from static public function fromArgPure<P,R,E>(r:R):AttemptArg<P,R,E>{
    return AttemptArgPure(r);
  }
}
typedef AttemptDef<I,O,E>               = FletcherDef<I,Upshot<O,E>,Nada>;

@:using(eu.ohmrun.fletcher.Attempt.AttemptLift)
@:forward abstract Attempt<I,O,E>(AttemptDef<I,O,E>) from AttemptDef<I,O,E> to AttemptDef<I,O,E>{
  static public var _(default,never) = AttemptLift;
  
  public inline function new(self) this = self;
  
  static public inline function bump<I,O,E>(self:AttemptArg<I,O,E>) {
    #if debug
      __.assert().exists(self); 
    #end
    //__.log().debug(_ -> _.pure(pos));
    return switch(self){
      case AttemptArgPure(r)            : pure(r); 
      case AttemptArgUpshot(res)           : fromUpshot(res);
      case AttemptArgFun1Upshot(fn)        : fromFun1Upshot(fn);
      case AttemptArgFun1Produce(fn)    : fromFun1Produce(fn); 
      case AttemptArgUnary1Produce(fn)  : fromUnary1Produce(fn);
      case AttemptArgFun1Provide(fn)    : fromFun1Provide(fn);
    }
  }
  static public inline function lift<I,O,E>(self:AttemptDef<I,O,E>) return new Attempt(self);

  static public function unit<I,E>():Attempt<I,I,E>{
    return lift(
      Fletcher.Anon((i:I,cont:Terminal<Upshot<I,E>,Nada>) -> {
        return cont.receive(cont.value(__.accept(i)));
      })
    );
  }
  @:noUsing static public function pure<I,O,E>(o:O):Attempt<I,O,E>{
    return fromUpshot(__.accept(o));
  }
  @:noUsing static public function fromUpshot<I,O,E>(res:Upshot<O,E>):Attempt<I,O,E>{
    return lift(
      Fletcher.Anon((_:I,cont:Waypoint<O,E>) -> {
        return cont.receive(cont.value(res));
      })
    );
  }
  @:from static public function fromFun1Upshot<Pi,O,E>(fn:Pi->Upshot<O,E>):Attempt<Pi,O,E>{
    return lift(Fletcher.Anon(
      (pI:Pi,cont:Waypoint<O,E>) -> {
        return cont.receive(cont.value(fn(pI)));
      }
    ));
  }
  @:from static public function fromFun1Produce<Pi,O,E>(fn:Pi->Produce<O,E>):Attempt<Pi,O,E>{
    return lift(
      Fletcher.Anon((pI:Pi,cont:Waypoint<O,E>) -> {
        return cont.receive(fn(pI).forward(Nada));
      })
    );
  }
  @:from static public function fromUnary1Produce<Pi,O,E>(fn:Unary<Pi,Produce<O,E>>):Attempt<Pi,O,E>{
    return fromFun1Produce(fn);
  }
  @:from static public function fromFun1Provide<Pi,O,E>(fn:Pi->Provide<O>):Attempt<Pi,O,E>{
    //__.log().debug(_ -> _.pure(pos));
    return lift(
      Fletcher.Anon(
        (pI:Pi,cont:Waypoint<O,E>) -> {
          final rest = fn(pI);
          #if debug
            __.assert().exists(rest);
          #end 
          return cont.receive(
            Produce.lift(
              rest.convert(Fletcher.Sync(__.accept))
            ).forward(Nada)
          );
        }
      )
    );
  }
  @:noUsing static public function fromFun1R<I,O,E>(fn:I->O):Attempt<I,O,E>{
    return lift(
      Fletcher.Anon((i,cont) -> cont.receive(cont.value(__.accept(fn(i)))))
    );
  }
  @:to public inline function toFletcher():Fletcher<I,Upshot<O,E>,Nada>{
    return this;
  }
  public function toModulate():Modulate<I,O,E>{
    return Modulate.lift(Fletcher.Anon(
      (i:Upshot<I,E>,cont:Waypoint<O,E>) -> 
        i.fold(
          (v) -> cont.receive(this.forward(v)),
          (e) -> cont.receive(cont.value(__.reject(e)))
        )
    ));  
  }
  public inline function environment(i:I,success:O->Void,?failure:Refuse<E>->Void):Fiber{
    return Modulate._.environment(toModulate(),i,success,failure);
  }
  public function mapi<Ii>(that:Ii->I):Attempt<Ii,O,E>{
    return Attempt._.mapi(this,that);
  }
}
class AttemptLift{
  static private function lift<I,O,E>(self:AttemptDef<I,O,E>)          return new Attempt(self);

  //static public inline function toFletcher<I,O,E>(self:AttemptDef<I,O,E>):Fletcher<I,O,E>{
    
  //}
  static public function then<I,O,Oi,E>(self:AttemptDef<I,O,E>,that:Modulate<O,Oi,E>):Attempt<I,Oi,E>{
    return lift(Fletcher.Then(self,that));
  }
  static public function rectify<I,O,Oi,E>(self:AttemptDef<I,O,E>,next:Reform<O,Oi,E>):Fletcher<I,Oi,Nada>{
    return Fletcher.lift(Fletcher.Then(lift(self).toFletcher(),next.toFletcher()));
  }
  static public function resolve<I,O,E>(self:AttemptDef<I,O,E>,next:Resolve<O,E>):Attempt<I,O,E>{
    return lift(self.then(next.toModulate()));
  }
  static public function reclaim<I,O,Oi,E>(self:AttemptDef<I,O,E>,next:Convert<O,Produce<Oi,E>>):Attempt<I,Oi,E>{
    return lift(
      then(
        self,
        next.toModulate()
      ).attempt(
        lift(Fletcher.Anon(
          (prd:Produce<Oi,E>,cont:Terminal<Upshot<Oi,E>,Nada>) ->
            cont.receive(prd.forward(Nada))
        ))
      )
    );
  }
  static public function recover<I,O,E>(self:AttemptDef<I,O,E>,next:Recover<O,E>):Attempt<I,O,E>{
    return lift(self.then(next.toModulate()));
  }
  static public function convert<I,O,Oi,E>(self:AttemptDef<I,O,E>,next:Convert<O,Oi>):Attempt<I,Oi,E>{
    return then(self,next.toModulate());
  }
  static public function errata<I,O,E,EE>(self:AttemptDef<I,O,E>,fn:Refuse<E>->Refuse<EE>):Attempt<I,O,EE>{
    return lift(Fletcher._.map(self,(oc) -> oc.errata(fn)));
  }
  static public function errate<I,O,E,EE>(self:AttemptDef<I,O,E>,fn:E->EE):Attempt<I,O,EE>{
    return lift(Fletcher._.map(self,(oc) -> oc.errate(fn)));
  }
  static public function attempt<I,O,Oi,E>(self:AttemptDef<I,O,E>,next:Attempt<O,Oi,E>):Attempt<I,Oi,E>{
    return then(self,next.toModulate());
  }
  static public function reframe<I,O,E>(self:AttemptDef<I,O,E>):Reframe<I,O,E>{ 
    return lift(self).toModulate().reframe();
  }
  static public function broach<I,O,E>(self:AttemptDef<I,O,E>):Attempt<I,Couple<I,O>,E>{
    return Attempt.lift(
      Fletcher.Anon(
        (ipt:I,cont:Terminal<Upshot<Couple<I,O>,E>,Nada>) -> {
          return cont.receive(
            lift(self).map(
              (o:O) -> __.couple(ipt,o)
            ).forward(ipt)
          );
        }
      )
    );
  }
  static public function provide<I,O,E>(self:AttemptDef<I,O,E>,i:I):Produce<O,E>{
    return Produce.lift(
      Fletcher.Anon(
        (_:Nada,cont) -> cont.receive(self.forward(i))
      )
   );
  }  
  static public function arrange<I,O,Oi,E>(self:AttemptDef<I,O,E>,then:Arrange<O,I,Oi,E>):Attempt<I,Oi,E>{
    return lift(
      Fletcher.Anon((p:I,cont:Waypoint<Oi,E>) -> 
        cont.receive(
          self.forward(p).flat_fold(
            ok -> then.forward(ok.map(__.couple.bind(_,p))),
            no -> cont.error(no) 
          )
        )
    ));
  }
  static public function mapi<I,Ii,O,E>(self:AttemptDef<I,O,E>,that:Ii->I):Attempt<Ii,O,E>{
    return lift(Fletcher._.mapi(lift(self).toFletcher(),that));
  }
  static public function modulate<I,O,Oi,E>(self:AttemptDef<I,O,E>,that:Modulate<O,Oi,E>):Attempt<I,Oi,E>{
    return lift(self.then(that));
  }
  static public function execute<I,O,E>(self:AttemptDef<I,O,E>,that:Execute<E>):Attempt<I,O,E>{
    return Attempt.lift(
      Fletcher.Then(
        self,
        Fletcher.Anon(
          (ipt:Upshot<O,E>,cont:Waypoint<O,E>) -> ipt.fold(
            o -> cont.receive(that.produce(Produce.pure(o)).forward(Nada)),
            e -> cont.receive(cont.value(__.reject(e)))
          )
        )
      )
    );
  }
  static public function command<I,O,E>(self:AttemptDef<I,O,E>,that:Command<O,E>):Attempt<I,O,E>{
    return Attempt.lift(
      Fletcher.Then(
        lift(self),
        Fletcher.Anon(
          (ipt:Upshot<O,E>,cont:Waypoint<O,E>) -> {
            __.log().debug(_ -> _.pure(ipt));
              return ipt.fold(
                o -> cont.receive(that.produce(Produce.pure(o)).forward(o)),
                e -> cont.receive(cont.value(__.reject(e)))
             );
          }
        )
      )
    );
  }
  static public function map<I,O,Oi,E>(self:AttemptDef<I,O,E>,fn:O->Oi):Attempt<I,Oi,E>{
    return Attempt.lift(
      Fletcher._.map(
        self,
        res -> res.map(fn)
      )
    );
  }
  static public function flat_map<I,O,Oi,E>(self:AttemptDef<I,O,E>,fn:O->Attempt<I,Oi,E>):Attempt<I,Oi,E>{
    return Attempt.lift(Fletcher.Anon(
      (ipt:I,cont:Terminal<Upshot<Oi,E>,Nada>) -> cont.receive(
        self.forward(ipt).flat_map(
          res -> res.fold(
            ok -> fn(ok).forward(ipt),
            no -> Receiver.issue(__.success(__.reject(no)))
          )
        )
      )
    ));
  }
  static public function produce<P, R, E>(self:AttemptDef<P, R, E>, i:P):Produce<R, E> {
		return Produce.lift(Fletcher.Anon((_:Nada, cont) -> cont.receive(self.forward(i))));
	}
  static public function adjust<P,R,Ri,E>(self:AttemptDef<P,R,E>,fn:R->Upshot<Ri,E>):Attempt<P,Ri,E>{
    return lift(Fletcher._.then(
      self,
      Fletcher.fromFun1R((res:Upshot<R,E>) -> res.flat_map(fn))
    ));
  }
}