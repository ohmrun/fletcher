package eu.ohmrun.fletcher;

typedef ProposeDef<O,E> = FletcherDef<Noise,Chunk<O,E>,Noise>;

@:using(eu.ohmrun.fletcher.Propose.ProposeLift)
abstract Propose<O,E>(ProposeDef<O,E>) from ProposeDef<O,E> to ProposeDef<O,E>{
  static public var _(default,never) = ProposeLift;
  public inline function new(self) this = self;
  @:noUsing static public inline function lift<O,E>(self:ProposeDef<O,E>):Propose<O,E> return new Propose(self);
    
  @:noUsing static public function fromChunk<O,E>(chunk:Chunk<O,E>):Propose<O,E>{
    return lift(Fletcher.pure(chunk));
  }
  @:noUsing static public function fromOption<O,E>(self:Option<O>):Propose<O,E>{
    return lift(Fletcher.pure(self.fold((o) -> Val(o),()->Tap)));
  }
  @:noUsing static public function make<O,E>(o:Null<O>):Propose<O,E>{
    return fromChunk(__.chunk(o));
  }
  @:noUsing static public function pure<O,E>(o:O):Propose<O,E>{
    return fromChunk(Val(o));
  }
  @:noUsing static public function fromRefuse<O,E>(e:Refuse<E>):Propose<O,E>{
    return fromChunk(End(e));
  }
  @:noUsing static public function unit<O,E>():Propose<O,E>{
    return lift(Fletcher.pure(Tap));
  }
  @:from @:noUsing static public function fromChunkThunk<O,E>(thunk:Thunk<Chunk<O,E>>):Propose<O,E>{
    return lift(
      Fletcher.Sync(
        (_:Noise) -> thunk()
      )
    );
  }
  public inline function toFletcher():Fletcher<Noise,Chunk<O,E>,Noise>{
    return this;
  }
  public function elide():Propose<Any,E>{
    return cast this;
  }
  private var self(get,never):Propose<O,E>;
  private function get_self():Propose<O,E> return lift(this);
  @:noUsing static public function bind_fold<T,O,E>(fn:T->O->Propose<O,E>,iterable:Iterable<T>,seed:O):Option<Propose<O,E>>{
    return iterable.toIter().lfold(
      (next:T,memo:Propose<O,E>) -> Propose.lift(
        memo.toFletcher().then(
          Fletcher.Anon(
            (res:Chunk<O,E>,cont:Terminal<Chunk<O,E>,Noise>) -> res.fold(
              (o) -> cont.receive(fn(next,o).forward(Noise)),
              (e) -> cont.value(End(e)).serve(),
              ()  -> cont.value(Tap).serve()
            )
          )
        )
      ),
      Propose.pure(seed)
    );
  }
  public function flat_map<Oi>(fn:O->ProposeDef<Oi,E>):Propose<Oi,E>{
    return _.flat_map(self,fn);
  }
}
class ProposeLift{
  static public function flat_map<O,Oi,E>(self:ProposeDef<O,E>,fn:O->ProposeDef<Oi,E>):Propose<Oi,E>{
    return Propose.lift(Fletcher.FlatMap(Propose.lift(self).toFletcher(),
      (chunk:Chunk<O,E>) -> 
        chunk.fold(
          (o) -> fn(o),
          (e) -> Propose.fromChunk(End(e)),
          ()  -> Propose.fromChunk(Tap)
        )
    ));
  }
  static public function convert<O,Oi,E>(self:ProposeDef<O,E>,next:Convert<O,Oi>):Propose<Oi,E>{
    return Propose.lift(Fletcher.Then(
      self,
      Fletcher.Anon(
        (ipt:Chunk<O,E>,cont:Terminal<Chunk<Oi,E>,Noise>) -> ipt.fold(
          (o) -> cont.receive(next.map(Val).forward(o)),
          (e) -> cont.value(End(e)).serve(),
          ()  -> cont.value(Tap).serve()
        )
      )
    ));
  }
  static public function attempt<O,Oi,E>(self:ProposeDef<O,E>,next:Attempt<O,Oi,E>):Propose<Oi,E>{
    return Propose.lift(Fletcher.Then(
      self,
      Fletcher.Anon(
        (ipt:Chunk<O,E>,cont:Terminal<Chunk<Oi,E>,Noise>) -> ipt.fold(
          (o) -> cont.receive(next.toFletcher().map((res:Upshot<Oi,E>) -> res.toChunk()).forward(o)),
          (e) -> cont.value(End(e)).serve(),
          ()  -> cont.value(Tap).serve()
        )
      )
    ));
  }

  static public function diffuse<O,Oi,E>(self:ProposeDef<O,E>,next:Diffuse<O,Oi,E>):Propose<Oi,E>{
    return Propose.lift(
      Fletcher.Then(
        self,
        next.toFletcher()
      )
    );
  }
  static public function or<O,E>(self:ProposeDef<O,E>,or:Void->Propose<O,E>):Propose<O,E>{
    return Propose.lift(
      Fletcher.Then(
        self,
        Fletcher.Anon(
          (ipt:Chunk<O,E>,cont:Terminal<Chunk<O,E>,Noise>) -> ipt.fold(
            (o) -> cont.value(Val(o)).serve(),
            (e) -> cont.value(End(e)).serve(),
            ()  -> cont.receive(or().forward(Noise))
          )
        )
      )
    );
  }
  static public function toProduce<O,E>(self:ProposeDef<O,E>):Produce<Option<O>,E>{
    return Produce.lift(
      Fletcher.lift(self).map(
        Chunk._.fold.bind(_,
          (o) -> __.accept(Some(o)),
          (e) -> __.reject(e),
          ()  -> __.accept(None)
        )
      )
    );
  }
  static public function materialise<O,E>(self:ProposeDef<O,E>):Propose<Option<O>,E>{
    return Propose.lift(
      Fletcher._.map(
        Fletcher.lift(self),
        (ipt:Chunk<O,E>) -> ipt.fold(
          (o) -> Val(__.option(o)),
          (e) -> End(e),
          ()  -> Val(None)
        )
      )
    );
  }
  static public function and<O,Oi,E>(self:Propose<O,E>,that:Propose<Oi,E>):Propose<Couple<O,Oi>,E>{
    return Propose.lift(
      Fletcher.Then(
        Fletcher.lift(self),
        Fletcher.Anon(
          (ipt:Chunk<O,E>,cont:Terminal<Chunk<Couple<O,Oi>,E>,Noise>) -> ipt.fold(
            (o) -> cont.receive(that.map(__.couple.bind(o)).forward(Noise)),
            (e) -> cont.value(End(e)).serve(),
            ()  -> cont.value(Tap).serve()
          )
        )
      )
    );
  }
  static public function command<O,E>(self:ProposeDef<O,E>,that:Command<O,E>):Execute<E>{
    return Execute.lift(
      Fletcher.Then(
        self,
        Fletcher.Anon(
          (ipt:Chunk<O,E>,cont:Terminal<Report<E>,Noise>) -> ipt.fold(
            o     -> cont.receive(that.forward(o)),
            e     -> cont.value(Report.pure(e)).serve(),
            ()    -> cont.value(Report.unit()).serve()
          )
        )
      )
    );
  }
  static public function before<O,E>(self:ProposeDef<O,E>,fn:Void->Void):Propose<O,E>{
    return Propose.lift(
      Fletcher.Then(
        Fletcher.Sync(((_) -> fn()).promote()),
        self
      )
    );
  }
  static public function after<O,E>(self:ProposeDef<O,E>,fn:Chunk<O,E>->Void):Propose<O,E>{
    return Propose.lift(
      Fletcher.Then(
        self,
        Fletcher.Sync(fn.promote())
      )
    );
  }
  static public inline function environment<O,E>(self:ProposeDef<O,E>,success:Option<O>->Void,failure:Refuse<E>->Void){
    return Fletcher._.environment(
      Fletcher.lift(self),
      Noise,
      (chunk) -> chunk.fold(
        (o) -> success(Some(o)),
        (e) -> failure(e),
        ()  -> success(None)
      ),
      (e) -> throw e
    );
  }
  static public function map<O,Oi,E>(self:ProposeDef<O,E>,then:O->Oi){
    return Propose.lift(
      Fletcher.Then(
        self,
        Fletcher.Sync(Chunk._.fold.bind(_,then.fn().then(Val),End,()->Tap))
      )
    );
  }
}