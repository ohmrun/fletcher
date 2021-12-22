package eu.ohmrun.fletcher;


typedef ReformDef<I,O,E>               = FletcherDef<Res<I,E>,O,Noise>;

@:forward abstract Reform<I,O,E>(ReformDef<I,O,E>) from ReformDef<I,O,E> to ReformDef<I,O,E>{
  public inline function new(self) this = self;
  @:noUsing static public inline function lift<I,O,E>(self:ReformDef<I,O,E>){
    return new Reform(self);
  }
  public function toModulate():Modulate<I,O,E>{
    return Modulate.lift(
      Fletcher.lift(this).map(__.accept)
    );
  }
  public inline function prj():ReformDef<I,O,E>{
    return this;
  }
  @:to public inline function toFletcher():Fletcher<Res<I,E>,O,Noise>{
    return this;
  }
} 