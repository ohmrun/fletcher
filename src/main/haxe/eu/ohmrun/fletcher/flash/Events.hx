package eu.ohmrun.flash.body;

class Events{
  static public function once<T:FlashEvent>(dispatcher:IEventDispatcher,key:String,fn:T->Void):Void{
    function handler(e:T){
      fn(e);
      dispatcher.removeEventListener(key,handler);
    }
    dispatcher.addEventListener(key,handler);
  }
  static public function project<T>(arw:Fletcher<IEventDispatcher,T>):IEventDispatcher->Handler<T>{
    return function(dispatcher:IEventDispatcher):Handler<T>{
      return function(cb:T->Void):Subscription{
        var done        = false;
        var subscription = new AnonymousSubscription(function(){
          done = true;
        });
        arw.augure(dispatcher).apply(printer());
        arw.tie(__.couple).then(
          function(l:IEventDispatcher,r:T){
            trace('here');
            cb(r);
            return done ? Done(Unit) : Cont(l);
          }.tupled()
        ).repeat().augure(dispatcher).apply(noop1);
        return subscription;
      }
    }
  }
}