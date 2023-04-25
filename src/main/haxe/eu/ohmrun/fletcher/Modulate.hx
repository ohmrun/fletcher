package eu.ohmrun.fletcher;


enum ModulateArgSum<P,R,E>{
	ModulateArgFun1Produce(arw:P->Produce<R, E>);
	ModulateArgAttempt(self:Attempt<P,R,E>);
	ModulateArgFletcher(arw:Fletcher<P, R, E>);
	//ModulateArgFunResUpshot(fn:Upshot<P,E>->Upshot<R,EE>);
	ModulateArgFunResRes0(fn:Upshot<P,E>->Upshot<R,E>);
	ModulateArgFun1Upshot(fn:P -> Upshot<R, E>);
	ModulateArgFun1R(fn:P -> R );
	ModulateArgUpshot(ocR:Upshot<R, E>);
	ModulateArgPure(o:R);
}
abstract ModulateArg<P,R,E>(ModulateArgSum<P,R,E>) from ModulateArgSum<P,R,E> to ModulateArgSum<P,R,E>{
	public function new(self) this = self;
	static public function lift<P,R,E>(self:ModulateArgSum<P,R,E>):ModulateArg<P,R,E> return new ModulateArg(self);

	public function prj():ModulateArgSum<P,R,E> return this;
	private var self(get,never):ModulateArg<P,R,E>;
	private function get_self():ModulateArg<P,R,E> return lift(this);

	@:from static public function fromModulateArgFun1Produce<P,R,E>(self:P->Produce<R, E>){
	return lift(ModulateArgFun1Produce(self));
	}
	@:from static public function fromModulateArgAttempt<P,R,E>(self:Attempt<P,R,E>){
		return lift(ModulateArgAttempt(self));
	}
	@:from static public function fromModulateArgFletcher<P,R,E>(self:Fletcher<P, R, E>){
		return lift(ModulateArgFletcher(self));
	}
	@:from static public function fromModulateArgFunResRes0<P,R,E>(self:Upshot<P,E>->Upshot<R,E>){
		return lift(ModulateArgFunResRes0(self));
	}
	@:from static public function fromModulateArgFun1Upshot<P,R,E>(self:P -> Upshot<R, E>){
		return lift(ModulateArgFun1Upshot(self));
	}
	@:from static public function fromModulateArgFun1R<P,R,E>(self:P -> R ){
		return lift(ModulateArgFun1R(self));
	}
	@:from static public function fromModulateArgUpshot<P,R,E>(self:Upshot<R, E>){
		return lift(ModulateArgUpshot(self));
	}
	@:from static public function fromModulateArgPure<P,R,E>(o:R){
		return lift(ModulateArgPure(o));
	}
	@:to public function toModulate(){
		return switch(this){
			case ModulateArgFun1Produce(arw)		: Modulate.fromFun1Produce(arw);
			case ModulateArgAttempt(self) 			: Modulate.fromAttempt(self);
			case ModulateArgFletcher(arw) 			: Modulate.fromFletcher(arw);
			case ModulateArgFunResRes0(fn) 			: Modulate.fromFunResRes0(fn);
			case ModulateArgFun1Upshot(fn)					: Modulate.fromFun1Upshot(fn);
			case ModulateArgFun1R(fn) 					: Modulate.fromFun1R(fn);
			case ModulateArgUpshot(ocR) 						: Modulate.fromUpshot(ocR);
			case ModulateArgPure(o) 						: Modulate.pure(o);
		}
	}
}
interface ModulateApi<I, O, E> extends FletcherApi<Upshot<I, E>, Upshot<O, E>, Noise>{
	
}
typedef ModulateDef<I, O, E> = FletcherDef<Upshot<I, E>, Upshot<O, E>, Noise>;

//@:using(eu.ohmrun.Fletcher.Lift)
@:using(eu.ohmrun.fletcher.Modulate.ModulateLift)
@:forward abstract Modulate<I, O, E>(ModulateDef<I, O, E>) from ModulateDef<I, O, E> to ModulateDef<I, O, E> {
	static public var _(default, never) = ModulateLift;

	public inline function new(self) this = self;


	@:from static public function fromApi<P,Pi,E>(self:ModulateApi<P,Pi,E>){
    return lift(self); 
  }
	@:noUsing static public inline function lift<I, O, E>(self:FletcherDef<Upshot<I, E>, Upshot<O, E>, Noise>):Modulate<I, O, E> {
		return new Modulate(self);
	}
	@:noUsing static public inline function bump<I, O, E>(self:ModulateArg<I,O,E>):Modulate<I, O, E> {
		return self.toModulate();
	}
	static public function unit<I, O, E>():Modulate<I, I, E> {
		return lift(Fletcher.fromFun1R((oc:Upshot<I, E>) -> oc));
	}

	@:noUsing static public function pure<I, O, E>(o:O):Modulate<I, O, E> {
		return fromUpshot(__.accept(o));
	}
	@:noUsing static inline public function Fun<I,O,E>(fn:I->O):Modulate<I,O,E>{
		return fromFun1R(fn);
	}
  @:noUsing static inline public function fromFun1Upshot<I, O, E>(fn:I -> Upshot<O, E>):Modulate<I, O, E> {
		return lift(Fletcher.fromFun1R((ocI:Upshot<I, E>) -> ocI.fold((i : I) -> fn(i), (e:Refuse<E>) -> __.reject(e))));
  }
  @:noUsing static public function fromFun1R<I, O, E>(fn:I -> O ):Modulate<I, O, E> {
		return lift(Fletcher.fromFun1R((ocI:Upshot<I, E>) -> ocI.fold((i : I) -> __.accept(fn(i)), (e:Refuse<E>) -> __.reject(e))));
	}
	@:noUsing static public function fromUpshot<I, O, E>(ocO:Upshot<O, E>):Modulate<I, O, E> {
		return lift(Fletcher.fromFun1R((ocI:Upshot<I, E>) -> ocI.fold((i : I) -> ocO, (e:Refuse<E>) -> __.reject(e))));
	}
	@:from @:noUsing static public function fromFunResRes0<I,O,E>(fn:Upshot<I,E>->Upshot<O,E>):Modulate<I,O,E>{
		return lift(Fletcher.Sync(
			(res:Upshot<I,E>) -> res.fold(
				ok -> fn(__.accept(ok)),
				no -> __.reject(no)
			)
		));
	}
	@:from @:noUsing static public function fromFunResUpshot<I,O,E,EE>(fn:Upshot<I,E>->Upshot<O,EE>):Modulate<I,O,EE>{
		return lift(Fletcher.Sync(
			(res:Upshot<I,EE>) -> res.fold(
				ok -> fn(__.accept(ok)),
				no -> __.reject(no)
			)
		));
	}
	@:noUsing static public function fromFletcher<I, O, E>(self:Fletcher<I, O, E>):Modulate<I, O, E> {
		return lift(
			Fletcher.Anon((p:Upshot<I,E>,cont:Waypoint<O,E>) -> cont.receive(
				p.fold(
					ok -> self.forward(ok).fold_mapp(
						ok -> __.success(__.accept(ok)),
						no -> __.success(__.reject(no.toRefuse())) 
					),
					no -> Receiver.value(__.reject(no))
				)
			)
		));
	}

	@:noUsing static public function fromAttempt<I, O, E>(self:Attempt<I,O,E>):Modulate<I, O, E> {
		return lift(
			Fletcher.Anon((p:Upshot<I,E>,cont:Waypoint<O,E>) -> p.fold(
				ok -> cont.receive(self.forward(ok)),
				no -> cont.receive(cont.value(__.reject(no)))
			))
		);
	}

	@:from @:noUsing static public function fromFun1Produce<I, O, E>(arw:I->Produce<O, E>):Modulate<I, O, E> {
		return lift(
			Fletcher.Anon(
				(i:Upshot<I, E>, cont:Waypoint<O,E>) -> 
					i.fold(
						(i) -> cont.receive(arw(i).forward(Noise)), 
						e -> cont.receive(cont.value(__.reject(e)))
					)
			)
		);
	}

	@:to public function toFletcher():Fletcher<Upshot<I, E>, Upshot<O, E>, Noise> return this;

	public inline function environment(i:I, success:O->Void, failure:Refuse<E>->Void):Fiber {
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
	public inline function prj():FletcherDef<Upshot<I,E>,Upshot<O,E>,Noise>{
		return this;
	}
}

class ModulateLift {
	static private function lift<I, O, E>(self:FletcherDef<Upshot<I, E>, Upshot<O, E>, Noise>):Modulate<I, O, E> {
		return new Modulate(self);
	}

	static public function or<Ii, Iii, O, E>(self:ModulateDef<Ii, O, E>, that:Modulate<Iii, O, E>):Modulate<Either<Ii, Iii>, O, E> {
		return lift(
			Fletcher.Anon(
				(ipt:Upshot<Either<Ii, Iii>, E>, cont:Terminal<Upshot<O, E>, Noise>) -> 
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
	static public function errata<I, O, E, EE>(self:ModulateDef<I, O, E>, fn:Refuse<E>->Refuse<EE>):Modulate<I, O, EE> {
		return lift(
			Fletcher.Anon(
				(i:Upshot<I, EE>,cont:Waypoint<O,EE>) -> i.fold(
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
			Fletcher.Anon((p:Upshot<I,E>,cont:Waypoint<Couple<O,I>,E>) -> cont.receive(
				self.forward(p).fold_mapp(
					ok -> __.success(ok.zip(p)),
					e  -> __.failure(e)
				)
			)
		));
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

	@:noUsing static public inline function environment<I, O, E>(self:ModulateDef<I, O, E>, i:I, success:O->Void, failure:Refuse<E>->Void):Fiber {
		return Fletcher._.environment(self, __.accept(i), (res) -> res.fold(success, failure), (err) -> throw err);
	}

	static public function produce<I, O, E>(self:ModulateDef<I, O, E>, i:Upshot<I,E>):Produce<O, E> {
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
		return lift(Fletcher.Anon((i:Upshot<I, E>, cont:Terminal<Upshot<Oi, E>, Noise>) -> cont.receive(self.forward(i).flat_fold(
				res -> then.forward(res.zip(i)),
				e 	-> cont.error(e)
			))
		));
	}

	static public function split<I, Oi, Oii, E>(self:ModulateDef<I, Oi, E>, that:Modulate<I, Oii, E>):Modulate<I, Couple<Oi, Oii>, E> {
		return lift(Fletcher._.split(self, that).map(__.decouple(Upshot._.zip)));
  }
  
  static public function broach<I, O, E>(self:ModulateDef<I, O, E>):Modulate<I, Couple<I,O>,E>{
    return lift(Fletcher._.broach(
      self
    ).then(
      Fletcher.Sync(
        (tp:Couple<Upshot<I,E>,Upshot<O,E>>) -> tp.decouple(
          (lhs,rhs) -> lhs.zip(rhs)
        )
      )
    ));
	}
	static public function flat_map<I,O,Oi,E>(self:ModulateDef<I,O,E>,fn:O->Modulate<I,Oi,E>):Modulate<I,Oi,E>{
		return lift(Fletcher.FlatMap(
			self,
			(res:Upshot<O,E>)->res.fold(
				ok -> fn(ok),
				no -> Modulate.fromUpshot(__.reject(no))
			)
		));
	}
	static public function command<I,O,E>(self:ModulateDef<I,O,E>,that:Command<O,E>):Modulate<I,O,E>{
    return Modulate.lift(
      Fletcher.Then(
        self,
        Fletcher.Anon(
          (ipt:Upshot<O,E>,cont:Terminal<Upshot<O,E>,Noise>) -> ipt.fold(
            o -> cont.receive(that.produce(Produce.pure(o)).forward(o)),
            e -> cont.receive(cont.value(__.reject(e)))
          )
        )
      )
    );
  }
	static public function adjust<P,R,Ri,E>(self:Modulate<P,R,E>,fn:R->Upshot<Ri,E>):Modulate<P,Ri,E>{
		return lift(Fletcher._.map(
			self,
			(res:Upshot<R,E>) -> res.flat_map(fn)
		));
	}
}