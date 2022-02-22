package eu.ohmrun.fletcher;
  
enum AttemptArgSum<P,R,E>{
  AttemptArgPure(r:R);
  AttemptArgRes(res:Res<R,E>);
  AttemptArgFun1Res(fn:P->Res<R,E>);
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
  @:from static public function fromArgFun1Res<P,R,E>(fn:P->Res<R,E>):AttemptArg<P,R,E>{
    return AttemptArgFun1Res(fn);
  }
  @:from static public function fromArgRes<P,R,E>(fn:Res<R,E>):AttemptArg<P,R,E>{
    return AttemptArgRes(fn);
  }
  @:from static public function fromArgPure<P,R,E>(r:R):AttemptArg<P,R,E>{
    return AttemptArgPure(r);
  }
}
typedef AttemptDef<I,O,E>               = FletcherDef<I,Res<O,E>,Noise>;

@:using(eu.ohmrun.fletcher.Attempt.AttemptLift)
@:forward abstract Attempt<I,O,E>(AttemptDef<I,O,E>) from AttemptDef<I,O,E> to AttemptDef<I,O,E>{
  static public var _(default,never) = AttemptLift;
  
  public inline function new(self) this = self;
  
  static public inline function bump<I,O,E>(self:AttemptArg<I,O,E>) return switch(self){
    case AttemptArgPure(r)            : pure(r); 
    case AttemptArgRes(res)           : fromRes(res);
    case AttemptArgFun1Res(fn)        : fromFun1Res(fn);
    case AttemptArgFun1Produce(fn)    : fromFun1Produce(fn); 
    case AttemptArgUnary1Produce(fn)  : fromUnary1Produce(fn);
    case AttemptArgFun1Provide(fn)    : fromFun1Provide(fn);
  }
  static public inline function lift<I,O,E>(self:AttemptDef<I,O,E>) return new Attempt(self);

  static public function unit<I,E>():Attempt<I,I,E>{
    return lift(
      (i:I,cont:Terminal<Res<I,E>,Noise>) -> {
        return cont.receive(cont.value(__.accept(i)));
      }
    );
  }
  @:noUsing static public function pure<I,O,E>(o:O):Attempt<I,O,E>{
    return fromRes(__.accept(o));
  }
  @:noUsing static public function fromRes<I,O,E>(res:Res<O,E>):Attempt<I,O,E>{
    return lift(
      (_:I,cont:Waypoint<O,E>) -> {
        return cont.receive(cont.value(res));
      }
    );
  }
  
  @:from static public function fromFun1Res<Pi,O,E>(fn:Pi->Res<O,E>):Attempt<Pi,O,E>{
    return lift(Fletcher.Anon(
      (pI:Pi,cont:Waypoint<O,E>) -> {
        return cont.receive(cont.value(fn(pI)));
      }
    ));
  }
  @:from static public function fromFun1Produce<Pi,O,E>(fn:Pi->Produce<O,E>):Attempt<Pi,O,E>{
    return lift(
      (pI:Pi,cont:Waypoint<O,E>) -> {
        return cont.receive(fn(pI).forward(Noise));
      }
    );
  }
  @:from static public function fromUnary1Produce<Pi,O,E>(fn:Unary<Pi,Produce<O,E>>):Attempt<Pi,O,E>{
    return fromFun1Produce(fn);
  }
  @:from static public function fromFun1Provide<Pi,O,E>(fn:Pi->Provide<O>):Attempt<Pi,O,E>{
    return lift(Fletcher.Anon(
      (pI:Pi,cont:Waypoint<O,E>) -> cont.receive(
        Produce.lift(
          fn(pI).convert(Fletcher.Sync(__.accept))
        ).forward(Noise)
      )
    ));
  }
  @:noUsing static public function fromFun1R<I,O,E>(fn:I->O):Attempt<I,O,E>{
    return lift(
      Fletcher.Anon((i,cont) -> cont.value(__.accept(fn(i))).serve())
    );
  }
  @:to public inline function toFletcher():Fletcher<I,Res<O,E>,Noise>{
    return this;
  }
  public function toModulate():Modulate<I,O,E>{
    return Modulate.lift(Fletcher.Anon(
      (i:Res<I,E>,cont:Waypoint<O,E>) -> 
        i.fold(
          (v) -> cont.receive(this.forward(v)),
          (e) -> cont.value(__.reject(e)).serve()
        )
    ));  
  }
  public inline function environment(i:I,success:O->Void,failure:Rejection<E>->Void):Fiber{
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
  static public function rectify<I,O,Oi,E>(self:AttemptDef<I,O,E>,next:Reform<O,Oi,E>):Fletcher<I,Oi,Noise>{
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
          (prd:Produce<Oi,E>,cont:Terminal<Res<Oi,E>,Noise>) ->
            cont.receive(prd.forward(Noise))
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
  static public function errata<I,O,E,EE>(self:AttemptDef<I,O,E>,fn:Rejection<E>->Rejection<EE>):Attempt<I,O,EE>{
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
        (ipt:I,cont:Terminal<Res<Couple<I,O>,E>,Noise>) -> {
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
        (_:Noise,cont) -> cont.receive(self.forward(i))
      )
   );
  }  
  static public function arrange<I,O,Oi,E>(self:AttemptDef<I,O,E>,then:Arrange<O,I,Oi,E>):Attempt<I,Oi,E>{
    return lift(
      (p:I,cont:Waypoint<Oi,E>) -> 
        cont.receive(
          self.forward(p).flat_fold(
            ok -> then.forward(ok.map(__.couple.bind(_,p))),
            no -> cont.error(no) 
          )
        )
    );
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
          (ipt:Res<O,E>,cont:Waypoint<O,E>) -> ipt.fold(
            o -> cont.receive(that.produce(Produce.pure(o)).forward(Noise)),
            e -> cont.value(__.reject(e)).serve()
          )
        )
      )
    );
  }
  static public function command<I,O,E>(self:AttemptDef<I,O,E>,that:Command<O,E>):Attempt<I,O,E>{
    return Attempt.lift(
      Fletcher.Then(
        self,
        Fletcher.Anon(
          (ipt:Res<O,E>,cont:Waypoint<O,E>) -> ipt.fold(
            o -> cont.receive(that.produce(Produce.pure(o)).forward(o)),
            e -> cont.value(__.reject(e)).serve()
          )
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
      (ipt:I,cont:Terminal<Res<Oi,E>,Noise>) -> cont.receive(
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
		return Produce.lift(Fletcher.Anon((_:Noise, cont) -> cont.receive(self.forward(i))));
	}
  static public function adjust<P,R,Ri,E>(self:AttemptDef<P,R,E>,fn:R->Res<Ri,E>):Attempt<P,Ri,E>{
    return lift(Fletcher._.then(
      self,
      Fletcher.fromFun1R((res:Res<R,E>) -> res.flat_map(fn))
    ));
  }
}