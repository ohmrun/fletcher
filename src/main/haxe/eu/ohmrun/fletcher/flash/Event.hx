package eu.ohmrun.flash.pack;

abstract Event<T:FlashEvent>(Fletcher<IEventDispatcher,T>) from Fletcher<IEventDispatcher,T> to Fletcher<IEventDispatcher,T>{
  public function new(v){
    this = v;
  }
  static public function pure<T:FlashEvent>(str:String):Event<T>{
    return fromString(str);
  }
  @:from static public function fromString<T:FlashEvent>(str:String):Event<T>{
    return function(dispatcher:IEventDispatcher,cont:T->Void):Void{
      Events.once(dispatcher,str,cont);
    }
  }
}