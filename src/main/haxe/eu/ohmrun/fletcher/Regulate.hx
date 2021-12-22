package eu.ohmrun.fletcher;


typedef RegulateDef<I,O,E>               = FletcherDef<Res<I,E>,O,Noise>;

@:forward abstract Regulate<I,O,E>(RegulateDef<I,O,E>) from RegulateDef<I,O,E> to RegulateDef<I,O,E>{
  public inline function new(self) this = self;
  @:noUsing static public inline function lift<I,O,E>(self:RegulateDef<I,O,E>){
    return new Regulate(self);
  }
  public function toCascade():Cascade<I,O,E>{
    return Cascade.lift(
      Fletcher.lift(this).map(__.accept)
    );
  }
  public inline function prj():RegulateDef<I,O,E>{
    return this;
  }
  @:to public inline function toFletcher():Fletcher<Res<I,E>,O,Noise>{
    return this;
  }
} 