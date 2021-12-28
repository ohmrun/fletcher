package eu.ohmrun.fletcher;

interface ModulateApi<I, O, E> extends FletcherApi<Res<I, E>, Res<O, E>, Noise>{
	
}
typedef ModulateDef<I, O, E> = FletcherDef<Res<I, E>, Res<O, E>, Noise>;

//@:using(eu.ohmrun.Fletcher.Lift)
@:using(eu.ohmrun.fletcher.Modulate.ModulateLift)
@:forward abstract Modulate<I, O, E>(ModulateDef<I, O, E>) from ModulateDef<I, O, E> to ModulateDef<I, O, E> {
	static public var _(default, never) = ModulateLift;

	public inline function new(self) this = self;


	@:from static public function fromApi<P,Pi,E>(self:ModulateApi<P,Pi,E>){
    return lift(self.defer); 
  }
		@:noUsing static public inline function lift<I, O, E>(self:FletcherDef<Res<I, E>, Res<O, E>, Noise>):Modulate<I, O, E> {
		return new Modulate(self);
	}

	static public function unit<I, O, E>():Modulate<I, I, E> {
		return lift(Fletcher.fromFun1R((oc:Res<I, E>) -> oc));
	}

	@:noUsing static public function pure<I, O, E>(o:O):Modulate<I, O, E> {
		return fromRes(__.accept(o));
	}
	@:noUsing static inline public function Fun<I,O,E>(fn:I->O):Modulate<I,O,E>{
		return fromFun1R(fn);
	}
  @:noUsing static inline public function fromFun1Res<I, O, E>(fn:I -> Res<O, E>):Modulate<I, O, E> {
		return lift(Fletcher.fromFun1R((ocI:Res<I, E>) -> ocI.fold((i : I) -> fn(i), (e:Rejection<E>) -> __.reject(e))));
  }
  @:noUsing static public function fromFun1R<I, O, E>(fn:I -> O ):Modulate<I, O, E> {
		return lift(Fletcher.fromFun1R((ocI:Res<I, E>) -> ocI.fold((i : I) -> __.accept(fn(i)), (e:Rejection<E>) -> __.reject(e))));
	}
	@:noUsing static public function fromRes<I, O, E>(ocO:Res<O, E>):Modulate<I, O, E> {
		return lift(Fletcher.fromFun1R((ocI:Res<I, E>) -> ocI.fold((i : I) -> ocO, (e:Rejection<E>) -> __.reject(e))));
	}
	@:from @:noUsing static public function fromFunResRes0<I,O,E>(fn:Res<I,E>->Res<O,E>):Modulate<I,O,E>{
		return lift(Fletcher.Sync(
			(res:Res<I,E>) -> res.fold(
				ok -> fn(__.accept(ok)),
				no -> __.reject(no)
			)
		));
	}
	@:from @:noUsing static public function fromFunResRes<I,O,E,EE>(fn:Res<I,E>->Res<O,EE>):Modulate<I,O,EE>{
		return lift(Fletcher.Sync(
			(res:Res<I,EE>) -> res.fold(
				ok -> fn(__.accept(ok)),
				no -> __.reject(no)
			)
		));
	}
	@:noUsing static public function fromFletcher<I, O, E>(arw:Fletcher<I, O, E>):Modulate<I, O, E> {
		return lift(
			(p:Res<I,E>,cont:Waypoint<O,E>) -> cont.receive(
				p.fold(
					ok -> arw.forward(ok).fold_mapp(
						ok -> __.success(__.accept(ok)),
						no -> __.success(__.reject(no.toError().except())) 
					),
					no -> Receiver.value(__.reject(no))
				)
			)
		);
	}

	@:noUsing static public function fromAttempt<I, O, E>(self:Attempt<I,O,E>):Modulate<I, O, E> {
		return lift(
			(p:Res<I,E>,cont:Waypoint<O,E>) -> p.fold(
				ok -> cont.receive(self.forward(ok)),
				no -> cont.receive(cont.value(__.reject(no)))
			)
		);
	}

	@:noUsing static public function fromProduce<O, E>(arw:Fletcher<Noise, Res<O, E>, Noise>):Modulate<Noise, O, E> {
		return lift(
			(p:Res<Noise,E>,cont:Waypoint<O,E>) -> 
				p.fold(
					_ -> cont.receive(arw.forward(Noise)),
					e -> cont.receive(cont.value(__.reject(e)))
				)
		);
	}

	@:from @:noUsing static public function fromFun1Produce<I, O, E>(arw:I->Produce<O, E>):Modulate<I, O, E> {
		return lift(
			Fletcher.Anon(
				(i:Res<I, E>, cont:Waypoint<O,E>) -> 
					i.fold(
						(i) -> cont.receive(arw(i).forward(Noise)), 
						typical_fail_handler(cont)				
					)
			)
		);
	}

	static private function typical_fail_handler<O, E>(cont:Terminal<Res<O, E>, Noise>) {
		return (e:Rejection<E>) -> cont.receive(cont.value(__.reject(e)));
	}

	@:to public inline function toFletcher():Fletcher<Res<I, E>, Res<O, E>, Noise> return this;

	public inline function environment(i:I, success:O->Void, failure:Rejection<E>->Void):Fiber {
		return _.environment(this, i, success, failure);
	}
	public inline function split<Oi>(that:Modulate<I, Oi, E>):Modulate<I, Couple<O, Oi>, E> {
		return _.split(this, that);
	}
	public inline function mapi<Ii>(fn:Ii->I):Modulate<Ii, O, E> {
		return _.mapi(this, fn);
  }
  public inline function convert<Oi>(that:Convert<O, Oi>):Modulate<I, Oi, E> {
		return _.convert(this, that);
  }
  public inline function broach():Modulate<I, Couple<I,O>,E>{ 
    return _.broach(this);
	}
	public inline function flat_map<Oi>(fn:O->Modulate<I,Oi,E>):Modulate<I,Oi,E>{
		return _.flat_map(this,fn);
	}
	public inline function prj():FletcherDef<Res<I,E>,Res<O,E>,Noise>{
		return this;
	}
}

class ModulateLift {
	static private function lift<I, O, E>(self:FletcherDef<Res<I, E>, Res<O, E>, Noise>):Modulate<I, O, E> {
		return new Modulate(self);
	}

	static public function or<Ii, Iii, O, E>(self:ModulateDef<Ii, O, E>, that:Modulate<Iii, O, E>):Modulate<Either<Ii, Iii>, O, E> {
		return lift(
			Fletcher.Anon(
				(ipt:Res<Either<Ii, Iii>, E>, cont:Terminal<Res<O, E>, Noise>) -> 
					ipt.fold(
						ok -> cont.receive(ok.fold(
							lhs -> self.forward(__.accept(lhs)),
							rhs -> that.forward(__.accept(rhs))
						)),
						no -> cont.receive(cont.value(__.reject(no)))
					)
			)
		);
	}
	static public function errata<I, O, E, EE>(self:ModulateDef<I, O, E>, fn:Rejection<E>->Rejection<EE>):Modulate<I, O, EE> {
		return lift(
			Fletcher.Anon(
				(i:Res<I, EE>,cont:Waypoint<O,EE>) -> i.fold(
					(i:I) -> 
						cont.receive(
							Fletcher._.map(
								self,
								o -> o.errata(fn)).forward(__.accept(i)
							)
						),
					(e) -> cont.receive(cont.value(__.reject(e)))
				)
			)
		);
	}

	static public function errate<I, O, E, EE>(self:ModulateDef<I, O, E>, fn:E->EE):Modulate<I, O, EE> {
		return errata(self, (e) -> e.errate(fn));
	}

	static public function reframe<I, O, E>(self:ModulateDef<I, O, E>):Reframe<I, O, E> {
		return lift(
			(p:Res<I,E>,cont:Waypoint<Couple<O,I>,E>) -> cont.receive(
				self.forward(p).fold_mapp(
					ok -> __.success(ok.zip(p)),
					e  -> __.failure(e)
				)
			)
		);
	}

	static public function modulate<I, O, Oi, E>(self:ModulateDef<I, O, E>, that:Modulate<O, Oi, E>):Modulate<I, Oi, E> {
		return lift(Fletcher.Then(self, that));
	}

	static public function attempt<I, O, Oi, E>(self:ModulateDef<I, O, E>, that:Attempt<O, Oi, E>):Modulate<I, Oi, E> {
		return modulate(self, that.toModulate());
	}

	static public function convert<I, O, Oi, E>(self:ModulateDef<I, O, E>, that:Convert<O, Oi>):Modulate<I, Oi, E> {
		return modulate(self, that.toModulate());
	}

	static public function map<I, O, Oi, E>(self:ModulateDef<I, O, E>, fn:O->Oi):Modulate<I, Oi, E> {
		return convert(self, Convert.fromFun1R(fn));
	}

	static public function mapi<I, Ii, O, E>(self:ModulateDef<I, O, E>, fn:Ii->I):Modulate<Ii, O, E> {
		return lift(Modulate.fromFletcher(Fletcher.fromFun1R(fn)).then(self));
	}

	static function typical_fail_handler<O, E>(cont:Terminal<Res<O, E>, Noise>):Rejection<E>->Work {
		return (e:Rejection<E>) ->  cont.receive(cont.value(__.reject(e)));
	}

	@:noUsing static public inline function environment<I, O, E>(self:ModulateDef<I, O, E>, i:I, success:O->Void, failure:Rejection<E>->Void):Fiber {
		return Fletcher._.environment(self, __.accept(i), (res) -> res.fold(success, failure), (err) -> throw err);
	}

	static public function produce<I, O, E>(self:ModulateDef<I, O, E>, i:Res<I,E>):Produce<O, E> {
		return Produce.lift(Fletcher.Anon((_:Noise, cont) -> cont.receive(self.forward(i))));
	}

	static public function reclaim<I, O, Oi, E>(self:ModulateDef<I, O, E>, that:Convert<O, Produce<Oi, E>>):Modulate<I, Oi, E> {
		return lift(modulate(self,
			that.toModulate()).attempt(
				Attempt.lift(
				Fletcher.Anon(
						(prd:Produce<Oi, E>, cont:Waypoint<Oi,E>) -> cont.receive(prd.forward(Noise))
					)
				)		
			)
		);
	}

	static public function arrange<I, O, Oi, E>(self:ModulateDef<I, O, E>, then:Arrange<O, I, Oi, E>):Modulate<I, Oi, E> {
		return lift(Fletcher.Anon((i:Res<I, E>, cont:Terminal<Res<Oi, E>, Noise>) -> cont.receive(self.forward(i).flat_fold(
				res -> then.forward(res.zip(i)),
				e 	-> cont.error(e)
			))
		));
	}

	static public function split<I, Oi, Oii, E>(self:ModulateDef<I, Oi, E>, that:Modulate<I, Oii, E>):Modulate<I, Couple<Oi, Oii>, E> {
		return lift(Fletcher._.split(self, that).map(__.decouple(Res._.zip)));
  }
  
  static public function broach<I, O, E>(self:ModulateDef<I, O, E>):Modulate<I, Couple<I,O>,E>{
    return lift(Fletcher._.broach(
      self
    ).then(
      Fletcher.Sync(
        (tp:Couple<Res<I,E>,Res<O,E>>) -> tp.decouple(
          (lhs,rhs) -> lhs.zip(rhs)
        )
      )
    ));
	}
	static public function flat_map<I,O,Oi,E>(self:ModulateDef<I,O,E>,fn:O->Modulate<I,Oi,E>):Modulate<I,Oi,E>{
		return lift(Fletcher.FlatMap(
			self,
			(res:Res<O,E>)->res.fold(
				ok -> fn(ok),
				no -> Modulate.fromRes(__.reject(no))
			)
		));
	}
	static public function command<I,O,E>(self:ModulateDef<I,O,E>,that:Command<O,E>):Modulate<I,O,E>{
    return Modulate.lift(
      Fletcher.Then(
        self,
        Fletcher.Anon(
          (ipt:Res<O,E>,cont:Terminal<Res<O,E>,Noise>) -> ipt.fold(
            o -> cont.receive(that.produce(Produce.pure(o)).forward(o)),
            e -> cont.receive(cont.value(__.reject(e)))
          )
        )
      )
    );
  }
}