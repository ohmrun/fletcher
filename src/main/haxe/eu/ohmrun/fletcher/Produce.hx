package eu.ohmrun.fletcher;

enum ProduceArgSum<O,E>{
  ProduceArgPure(o:O);
  ProduceArgSync(res:Res<O,E>);
  ProduceArgThunk(fn:Thunk<Res<O,E>>);
  ProduceArgRejection(rejection:Rejection<E>);
  ProduceArgPledge(pledge:Pledge<O,E>);
  ProduceArgFunXProduce(fn:Void->Produce<O,E>);
  ProduceArgFletcher(fletcher:Fletcher<Noise,O,E>);
}
abstract ProduceArg<O,E>(ProduceArgSum<O,E>) from ProduceArgSum<O,E> to ProduceArgSum<O,E>{
  public function new(self) this = self;
  static public function lift<O,E>(self:ProduceArgSum<O,E>):ProduceArg<O,E> return new ProduceArg(self);

  public function prj():ProduceArgSum<O,E> return this;
  private var self(get,never):ProduceArg<O,E>;
  private function get_self():ProduceArg<O,E> return lift(this);
  
  @:from static public function fromFunXProduce<O,E>(fn:Void->Produce<O,E>):ProduceArg<O,E>{
    return ProduceArgFunXProduce(fn);
  }
  @:from static public function fromFletcher<O,E>(fletcher:Fletcher<Noise,O,E>):ProduceArg<O,E>{
    return ProduceArgFletcher(fletcher);
  }
  @:from static public function fromPledge<O,E>(pledge:Pledge<O,E>):ProduceArg<O,E>{
    return ProduceArgPledge(pledge);
  }
  @:from static public function fromRejection<O,E>(rejection:Rejection<E>):ProduceArg<O,E>{
    return ProduceArgRejection(rejection);
  }
  @:from static public function fromThunk<O,E>(fn:Thunk<Res<O,E>>):ProduceArg<O,E>{
    return ProduceArgThunk(fn);
  }
  @:from static public function fromSync<O,E>(res:Res<O,E>):ProduceArg<O,E>{
    return ProduceArgSync(res);
  }
  @:from static public function fromPure<O,E>(o:O):ProduceArg<O,E>{
    return ProduceArgPure(o);
  }
}
typedef ProduceDef<O,E> = FletcherDef<Noise,Res<O,E>,Noise>;

@:using(eu.ohmrun.fletcher.Produce.ProduceLift)
@:forward(then) abstract Produce<O,E>(ProduceDef<O,E>) from ProduceDef<O,E> to ProduceDef<O,E>{
  static public var _(default,never) = ProduceLift;

  public inline function new(self:ProduceDef<O,E>) this = self;

  @:noUsing static public inline function lift<O,E>(self:ProduceDef<O,E>):Produce<O,E> return new Produce(self);

  @:noUsing static public inline function bump<O,E>(self:ProduceArg<O,E>):Produce<O,E>{
    return switch(self){
      case ProduceArgPure(o)              : pure(o);
      case ProduceArgSync(res)            : Sync(res);
      case ProduceArgThunk(fn)            : Thunk(fn);
      case ProduceArgRejection(rejection) : fromRejection(rejection);
      case ProduceArgPledge(pledge)       : fromPledge(pledge);
      case ProduceArgFunXProduce(fn)      : fromFunXProduce(fn);
      case ProduceArgFletcher(fletcher)   : fromFletcher(fletcher);
    }
  }
  @:noUsing static public function Sync<O,E>(result:Res<O,E>):Produce<O,E>{
    return Produce.lift(
      (_:Noise,cont) -> cont.value(result).serve()
    );
  }
  @:noUsing static public function Thunk<O,E>(result:Thunk<Res<O,E>>):Produce<O,E>{
    return Produce.lift(
      (_:Noise,cont) -> cont.value(result()).serve()
    );
  }
  @:from @:noUsing static public function fromFunXProduce<O,E>(self:Void->Produce<O,E>):Produce<O,E>{
    return lift(Fletcher.Anon(
      (_:Noise,cont:Terminal<Res<O,E>,Noise>) -> cont.receive(self().forward(Noise))
    ));
  }
  @:noUsing static public function fromRejection<O,E>(e:Rejection<E>):Produce<O,E>{
    return Sync(__.reject(e));
  }
  @:noUsing static public function pure<O,E>(v:O):Produce<O,E>{
    return Sync(__.accept(v));
  }
  @:noUsing static public function accept<O,E>(v:O):Produce<O,E>{
    return Sync(__.accept(v));
  }
  @:noUsing static public function reject<O,E>(e:Rejection<E>):Produce<O,E>{
    return Sync(__.reject(e));
  }
  @:from @:noUsing static public function fromRes<O,E>(res:Res<O,E>):Produce<O,E>{
    return Sync(res);
  }
  @:from @:noUsing static public function fromFunXRes<O,E>(fn:Void->Res<O,E>):Produce<O,E>{
    return Thunk(fn);
  }
  
  @:from @:noUsing static public function fromPledge<O,E>(pl:Pledge<O,E>):Produce<O,E>{
    return lift(
      Fletcher.Anon(      
        (_:Noise,cont:Terminal<Res<O,E>,Noise>) -> {
          return cont.later(
            pl.fold(
              (x) -> __.success(__.accept(x)),
              (e) -> __.success(__.reject(e))
            )
          ).serve();
        }
      )
    );
  }
  
  @:noUsing static public function fromFunXR<O,E>(fn:Void->O):Produce<O,E>{
    return lift(
      Fletcher.fromFun1R(
        (_:Noise) -> __.accept(fn())
      )
    ); 
  }
  @:noUsing static public function fromFletcher<O,E>(arw:Fletcher<Noise,O,E>):Produce<O,E>{
    return lift(
      (_:Noise,cont:Waypoint<O,E>) -> cont.receive(
          arw.forward(Noise).fold_mapp(
            (ok:O)          -> __.success(__.accept(ok)),
            (no:Defect<E>)  -> __.success(__.reject(no.toError().except()))
          )
        )
    );
  }
  static public function bind_fold<P,O,R,E>(data:Iter<P>,fn:P->R->Produce<R,E>,r:R):Produce<R,E>{
    return data.lfold(
      (next:P,memo:Produce<R,E>) -> {
        return memo.flat_map(
          r -> fn(next,r)
        );
      },
      pure(r)
    );
  }
  static public function fromProvide<O,E>(self:Provide<Res<O,E>>):Produce<O,E>{
    return Produce.lift(Fletcher.Anon(
      (_:Noise,cont:Terminal<Res<O,E>,Noise>) -> cont.receive(self.forward(Noise))
    ));
  }
  public inline function environment(success:O->Void,failure:Rejection<E>->Void):Fiber{
    return Fletcher._.environment(
      this,
      Noise,
      (res:Res<O,E>) -> {
        res.fold(success,failure);
      },
      __.crack
    );
  }
  @:to public inline function toFletcher():Fletcher<Noise,Res<O,E>,Noise>{
    return this;
  }
  @:to public function toPropose():Propose<O,E>{
    return Propose.lift(Fletcher._.map(this,(res:Res<O,E>) -> res.fold(Val,End)));
  }
  private var self(get,never):Produce<O,E>;
  private function get_self():Produce<O,E> return this;

  public function prj():ProduceDef<O,E>{
    return this;
  }
  public inline function fudge<O,E>(){
    return _.fudge(this);
  }
  public function flat_map<Oi>(fn:O->Produce<Oi,E>):Produce<Oi,E>{
    return _.flat_map(this,fn);
  }
}
class ProduceLift{
  @:noUsing static private function lift<O,E>(self:ProduceDef<O,E>):Produce<O,E> return Produce.lift(self);
  
  static public function map<I,O,Z,E>(self:ProduceDef<O,E>,fn:O->Z):Produce<Z,E>{
    return lift(self.then(
      Fletcher.fromFun1R(
        (oc:Res<O,E>) -> oc.map(fn)
      )
    ));
  }
  static public function errata<O,E,EE>(self:ProduceDef<O,E>,fn:Rejection<E>->Rejection<EE>):Produce<O,EE>{
    return lift(self.then(
      Fletcher.fromFun1R(
        (oc:Res<O,E>) -> oc.errata(fn)
      )
    ));
  }
  static public function errate<O,E,EE>(self:ProduceDef<O,E>,fn:E->EE):Produce<O,EE>{
    return errata(self,(er) -> er.errate(fn));
  }
  static public function point<O,E>(self:ProduceDef<O,E>,success:O->Execute<E>):Execute<E>{
    return Execute.lift(
      Fletcher.Anon(
        (_:Noise,cont:Terminal<Report<E>,Noise>) -> cont.receive(
          self.forward(Noise).flat_fold(
            res -> res.fold(
              ok -> success(ok).forward(Noise),
              er -> cont.value(Report.pure(er))
            ),
            err -> cont.error(err)
          )
        ) 
      )
    );
  }
  static public function provide<O,E>(self:ProduceDef<O,E>):Provide<O>{
    return Provide.lift(
      Fletcher._.map(self,
        res -> res.fold(
          (ok)  -> ok,
          (e)   -> throw(e)
        )
      )
    );
  }
  static public function convert<O,Oi,E>(self:ProduceDef<O,E>,then:Convert<O,Oi>):Produce<Oi,E>{
    return lift(Fletcher.Then(self,(Convert._.toModulate(then).toFletcher())));
  }
  static public function recover<O,E>(self:ProduceDef<O,E>,rec:Recover<O,E>):Provide<O>{
    return Provide.lift(self.then(rec.toReform()));
  }
  static public function attempt<O,Oi,E>(self:ProduceDef<O,E>,that:Attempt<O,Oi,E>):Produce<Oi,E>{
    return lift(self.then(that.toModulate()));
  }
  static public function deliver<O,E>(self:ProduceDef<O,E>,fn:O->Void):Execute<E>{
    return Execute.lift(self.then(
      Fletcher.Sync(
        (res:Res<O,E>) -> res.fold(
          (s) -> {
            fn(s);
            return Report.unit();
          },
          (e) -> Report.pure(e)
        )
      )
    ));
  }
  static public function reclaim<O,Oi,E>(self:ProduceDef<O,E>,next:Convert<O,Produce<Oi,E>>):Produce<Oi,E>{
    return lift(
      self.then(
        next.toModulate().toFletcher()
      )).attempt(
        Attempt.lift(Fletcher.Anon(
          (prd:Produce<Oi,E>,cont:Terminal<Res<Oi,E>,Noise>) -> cont.receive(prd.forward(Noise))
        ))
      );
  }
  static public function arrange<S,O,Oi,E>(self:ProduceDef<O,E>,next:Arrange<O,S,Oi,E>):Attempt<S,Oi,E>{
    return Attempt.lift(Fletcher.Anon(
      (i:S,cont:Terminal<Res<Oi,E>,Noise>) -> cont.receive(self.forward(Noise).flat_fold(
        res -> next.forward(res.map(__.couple.bind(_,i))),
        err -> cont.error(err)
      ))
    ));
  }
  static public function rearrange<S,O,Oi,E>(self:ProduceDef<O,E>,next:Arrange<Res<O,E>,S,Oi,E>):Attempt<S,Oi,E>{
    return Attempt.lift(
      Fletcher.Anon(
        (i:S,cont:Terminal<Res<Oi,E>,Noise>) -> 
          self.forward(Noise).flat_fold(
            res -> next.forward(__.accept(__.couple(res,i))),
            no  -> cont.error(no)
          ).serve()
      ) 
    );
  }
  static public function modulate<O,Oi,E>(self:ProduceDef<O,E>,that:Modulate<O,Oi,E>):Produce<Oi,E>{
    return lift(self.then(that));
  }
  static public inline function fudge<O,E>(self:ProduceDef<O,E>):O{
    return Fletcher._.fudge(self,Noise).fudge();
  }
  static public inline function force<O,E>(self:ProduceDef<O,E>):Res<O,E>{
    return Fletcher._.force(self,Noise).fudge();
  }
  static public function flat_map<O,Oi,E>(self:ProduceDef<O,E>,that:O->Produce<Oi,E>):Produce<Oi,E>{
    return lift(
      Fletcher.FlatMap(
        self,
        (res:Res<O,E>) -> res.fold(
          (o) -> that(o),
          (e) -> Produce.fromRes(__.reject(e))
        )
      )
    );
  }
  static public function fold_flat_map<O,Oi,E>(self:ProduceDef<O,E>,that:Res<O,E>->Produce<Oi,E>):Produce<Oi,E>{
    return lift(
      Fletcher.FlatMap(
        self,
        (res:Res<O,E>) -> that(res).prj()
      )
    );
  }
  static public function then<O,Oi,E>(self:ProduceDef<O,E>,that:Fletcher<Res<O,E>,Oi,Noise>):Provide<Oi>{
    return Provide.lift(Fletcher.Then(self,that));
  }
  static public function split<O,Oi,E>(self:ProduceDef<O,E>,that:Produce<Oi,E>):Produce<Couple<O,Oi>,E>{
    return lift(Fletcher._.split(self,that).then(
      Fletcher.fromFun1R(
        __.decouple((l:Res<O,E>,r:Res<Oi,E>) -> l.zip(r))
      )
    ));
  }
  static public function adjust<O,Oi,E>(self:ProduceDef<O,E>,fn:O->Res<Oi,E>):Produce<Oi,E>{
    return lift(Fletcher._.then(
      self,
      Fletcher.fromFun1R((res:Res<O,E>) -> res.flat_map(fn))
    ));
  }
  static public function pledge<O,E>(self:ProduceDef<O,E>):Pledge<O,E>{
    return Pledge.lift(
      (Fletcher._.future(self,Noise)).map(
        (outcome:Outcome<Res<O,E>,Defect<Noise>>) -> (outcome.fold(
          (x:Res<O,E>)      -> x,
          (e:Defect<Noise>) -> __.reject(e.elide().toError().except())
        ))
      )
    );
  }
}