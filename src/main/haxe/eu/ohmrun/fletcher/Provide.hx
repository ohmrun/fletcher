package eu.ohmrun.fletcher;

typedef ProvideDef<O> = ConvertDef<Noise,O>;
@:using(eu.ohmrun.fletcher.Provide.ProvideLift)
abstract Provide<O>(ProvideDef<O>) from ProvideDef<O> to ProvideDef<O>{
  static public var _(default,never) = ProvideLift;
  public inline function new(self) this = self;
  static public inline function lift<O>(self:ProvideDef<O>):Provide<O> return new Provide(self);

  // @:from static public inline function fromFunTerminalWork<O>(fn:Terminal<O,Noise>->Work):Provide<O>{
  //   return lift(
  //     Fletcher.Anon(
  //       (i:Noise,cont:Terminal<O,Noise>) -> fn(cont)
  //     )
  //   );
  // }
  @:noUsing static public inline function pure<O>(v:O):Provide<O>{
    return lift(
      (_:Noise,cont:Terminal<O,Noise>) -> cont.receive(cont.value(v))
    );
  }
  @:noUsing static public inline function fromFuture<O>(future:Future<O>):Provide<O>{
    return lift(
      (_:Noise,cont:Terminal<O,Noise>) -> cont.later(future.map(__.success)).serve()
    );
  }
  @:from static public inline function fromFunXR<O>(fn:Void->O):Provide<O>{
    return lift(
      (_:Noise,cont:Terminal<O,Noise>) -> cont.value(fn()).serve()
    );
  }
  @:from static public inline function fromFunXFuture<O>(fn:Void->Future<O>):Provide<O>{
    return lift(
      (_:Noise,cont:Terminal<O,Noise>) -> cont.later(fn().map(__.success)).serve()
    );
  }
  @:noUsing static public inline function fromFunTerminalWork<O>(fn:Terminal<O,Noise>->Work):Provide<O>{
    return lift(
      (_:Noise,cont:Terminal<O,Noise>) -> fn(cont)
    );
  }
  static public inline function bind_fold<T,O>(fn:Convert<Couple<T,O>,O>,arr:Cluster<T>,seed:O):Provide<O>{
    return arr.lfold(
      (next:T,memo:Provide<O>) -> {
        return memo.convert(
          Convert.fromFun1Provide(
            (o) -> fn.provide(__.couple(next,o))
          )
        );
      },
      Provide.pure(seed)
    );
  }
  @:to public inline function toFletcher():Fletcher<Noise,O,Noise>{
    return this;
  }
  public function prj():ProvideDef<O> return this;
  private var self(get,never):Provide<O>;
  private function get_self():Provide<O> return lift(this);

  public inline function fudge(){
    return _.fudge(this);
  }
}

class ProvideLift{
  static public inline function environment<O>(self:Provide<O>,handler:O->Void):Fiber{
    return Fletcher._.environment(
      self,
      Noise,
      (o) -> {
        handler(o);
      },
      (e) -> {
        __.log().fatal(_ -> _.pure(e));
        throw(e);
      }
    );
  }
  static public function flat_map<O,Oi>(self:Provide<O>,fn:O->ProvideDef<Oi>):Provide<Oi>{
    return Provide.lift(Fletcher.FlatMap(self.toFletcher(),fn));
  }
  static public function and<Oi,Oii>(lhs:ProvideDef<Oi>,rhs:ProvideDef<Oii>):Provide<Couple<Oi,Oii>>{
    return Provide.lift(Fletcher._.pinch(
        lhs,
        rhs
    ));
  }
  static public function convert<O,Oi>(self:ProvideDef<O>,that:Convert<O,Oi>):Provide<Oi>{
    return Provide.lift(Convert._.then(
      self,
      that
    ));
  }
  static public function toProduce<O,E>(self:ProvideDef<O>):Produce<O,E>{
    return Produce.lift(Fletcher.Then(self,Fletcher.Sync(__.accept)));
  }
  static public function attempt<O,Oi,E>(self:Provide<O>,that:Attempt<O,Oi,E>):Produce<Oi,E>{
    return toProduce(self).attempt(that);
  }
  static public function map<O,Oi>(self:ProvideDef<O>,fn:O->Oi):Provide<Oi>{
    return Provide.lift(
      Fletcher._.then(
        self,
        Fletcher.Sync(fn)
      )
    );
  }
  static public inline function fudge<O>(self:Provide<O>):O{
    return Fletcher._.fudge(self,Noise);
  }
static public function then<O,Oi>(self:ProvideDef<O>,that:Fletcher<O,Oi,Noise>):Provide<Oi>{
    return Provide.lift(Fletcher.Then(self,that));
  }
  //static public inline function future<O>(self:Provide<O>)  
}