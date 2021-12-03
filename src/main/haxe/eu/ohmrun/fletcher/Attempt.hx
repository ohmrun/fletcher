package eu.ohmrun.fletcher;
        
typedef AttemptDef<I,O,E>               = FletcherDef<I,Res<O,E>,Noise>;

@:using(eu.ohmrun.fletcher.Attempt.AttemptLift)
@:forward abstract Attempt<I,O,E>(AttemptDef<I,O,E>) from AttemptDef<I,O,E> to AttemptDef<I,O,E>{
  static public var _(default,never) = AttemptLift;
  
  public inline function new(self) this = self;
  

  static public inline function lift<I,O,E>(self:AttemptDef<I,O,E>) return new Attempt(self);

  static public function unit<I,E>():Attempt<I,I,E>{
    return lift(
      (i:I,cont:Terminal<Res<I,E>,Noise>) -> {
        return cont.value(__.accept(i)).serve();
      }
    );
  }
  @:noUsing static public function pure<I,O,E>(o:O):Attempt<I,O,E>{
    return fromRes(__.accept(o));
  }
  @:noUsing static public function fromRes<I,O,E>(res:Res<O,E>):Attempt<I,O,E>{
    return lift(
      (_:I,cont:Waypoint<O,E>) -> {
        return cont.value(res).serve();
      }
    );
  }
  
  @:from static public function fromFun1Res<Pi,O,E>(fn:Pi->Res<O,E>):Attempt<Pi,O,E>{
    return lift(Fletcher.Anon(
      (pI:Pi,cont:Waypoint<O,E>) -> {
        return cont.value(fn(pI)).serve();
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
  public function toCascade():Cascade<I,O,E>{
    return Cascade.lift(Fletcher.Anon(
      (i:Res<I,E>,cont:Waypoint<O,E>) -> 
        i.fold(
          (v) -> cont.receive(this.forward(v)),
          (e) -> cont.value(__.reject(e)).serve()
        )
    ));  
  }
  public inline function environment(i:I,success:O->Void,failure:Exception<E>->Void):Fiber{
    return Cascade._.environment(toCascade(),i,success,failure);
  }
  public function mapi<Ii>(that:Ii->I):Attempt<Ii,O,E>{
    return Attempt._.mapi(this,that);
  }
}
class AttemptLift{
  static private function lift<I,O,E>(self:AttemptDef<I,O,E>)          return new Attempt(self);

  //static public inline function toFletcher<I,O,E>(self:Attempt<I,O,E>):Fletcher<I,O,E>{
    
  //}
  static public function then<I,O,Oi,E>(self:Attempt<I,O,E>,that:Cascade<O,Oi,E>):Attempt<I,Oi,E>{
    return lift(Fletcher.Then(self,that));
  }
  static public function rectify<I,O,Oi,E>(self:Attempt<I,O,E>,next:Rectify<O,Oi,E>):Fletcher<I,Oi,Noise>{
    return Fletcher.lift(Fletcher.Then(self.toFletcher(),next.toFletcher()));
  }
  static public function resolve<I,O,E>(self:Attempt<I,O,E>,next:Resolve<O,E>):Attempt<I,O,E>{
    return lift(self.then(next.toCascade()));
  }
  static public function reclaim<I,O,Oi,E>(self:Attempt<I,O,E>,next:Convert<O,Produce<Oi,E>>):Attempt<I,Oi,E>{
    return lift(
      then(
        self,
        next.toCascade()
      ).attempt(
        lift(Fletcher.Anon(
          (prd:Produce<Oi,E>,cont:Terminal<Res<Oi,E>,Noise>) ->
            cont.receive(prd.forward(Noise))
        ))
      )
    );
  }
  static public function recover<I,O,E>(self:Attempt<I,O,E>,next:Recover<O,E>):Attempt<I,O,E>{
    return lift(self.then(next.toCascade()));
  }
  static public function convert<I,O,Oi,E>(self:Attempt<I,O,E>,next:Convert<O,Oi>):Attempt<I,Oi,E>{
    return then(self,next.toCascade());
  }
  static public function errata<I,O,E,EE>(self:Attempt<I,O,E>,fn:Exception<E>->Exception<EE>):Attempt<I,O,EE>{
    return lift(Fletcher._.map(self,(oc) -> oc.errata(fn)));
  }
  static public function errate<I,O,E,EE>(self:Attempt<I,O,E>,fn:E->EE):Attempt<I,O,EE>{
    return lift(Fletcher._.map(self,(oc) -> oc.errate(fn)));
  }
  static public function attempt<I,O,Oi,E>(self:Attempt<I,O,E>,next:Attempt<O,Oi,E>):Attempt<I,Oi,E>{
    return then(self,next.toCascade());
  }
  static public function reframe<I,O,E>(self:Attempt<I,O,E>):Reframe<I,O,E>{ 
    return self.toCascade().reframe();
  }
  static public function broach<I,O,E>(self:Attempt<I,O,E>):Attempt<I,Couple<I,O>,E>{
    return Attempt.lift(
      Fletcher.Anon(
        (ipt:I,cont:Terminal<Res<Couple<I,O>,E>,Noise>) -> {
          return cont.receive(
            self.map(
              (o:O) -> __.couple(ipt,o)
            ).forward(ipt)
          );
        }
      )
    );
  }
  static public function provide<I,O,E>(self:Attempt<I,O,E>,i:I):Produce<O,E>{
    return Produce.lift(
      Fletcher.Anon(
        (_:Noise,cont) -> cont.receive(self.forward(i))
      )
   );
  }  
  static public function arrange<I,O,Oi,E>(self:Attempt<I,O,E>,then:Arrange<O,I,Oi,E>):Attempt<I,Oi,E>{
    return lift(
      (p:I,cont:Waypoint<Oi,E>) -> 
        self.forward(p).flat_fold(
          ok -> then.forward(ok.map(__.couple.bind(_,p))),
          no -> cont.error(no) 
        ).serve()
    );
  }
  static public function mapi<I,Ii,O,E>(self:Attempt<I,O,E>,that:Ii->I):Attempt<Ii,O,E>{
    return lift(Fletcher._.mapi(self.toFletcher(),that));
  }
  static public function cascade<I,O,Oi,E>(self:Attempt<I,O,E>,that:Cascade<O,Oi,E>):Attempt<I,Oi,E>{
    return lift(self.then(that));
  }
  static public function execute<I,O,E>(self:Attempt<I,O,E>,that:Execute<E>):Attempt<I,O,E>{
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
  static public function command<I,O,E>(self:Attempt<I,O,E>,that:Command<O,E>):Attempt<I,O,E>{
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
  static public function map<I,O,Oi,E>(self:Attempt<I,O,E>,fn:O->Oi):Attempt<I,Oi,E>{
    return Attempt.lift(
      Fletcher._.map(
        self,
        res -> res.map(fn)
      )
    );
  }
}