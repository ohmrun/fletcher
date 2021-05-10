package eu.ohmrun.fletcher;

typedef RectifyDef<I,O,E>               = FletcherDef<Res<I,E>,O,Noise>;

@:forward abstract Rectify<I,O,E>(RectifyDef<I,O,E>) from RectifyDef<I,O,E> to RectifyDef<I,O,E>{
  public inline function new(self) this = self;
  @:noUsing static public inline function lift<I,O,E>(self:RectifyDef<I,O,E>){
    return new Rectify(self);
  }
  public function toCascade():Cascade<I,O,E>{
    return Cascade.lift(
      Fletcher.lift(this).map(__.accept)
    );
  }
  public inline function prj():RectifyDef<I,O,E>{
    return this;
  }
  @:to public inline function toFletcher():Fletcher<Res<I,E>,O,Noise>{
    return this;
  }
} 