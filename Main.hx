using eu.ohmrun.Fletcher;

using tink.CoreApi;
using stx.Nano;
using stx.unit.Test;
using stx.Fn;

class Main{
  static public function main(){
    __.unit(
      [new Test()],
      []
    );
  }
}
class Test extends TestCase{
  public function test(){
    
    var a = Terminal.unit().issue(__.success(1));
    // var b = a.apply(
    //   (v) -> {
    //     trace(v);
    //     return Work.unit();
    //   }
    // );
    var a = function(v:Int,cont:Terminal<Int,Dynamic>):Work{
      var ft = Future.trigger();
          trace('a called with $v');
          ft.trigger(__.success(v+1));
      var a  = cont.later(ft).map(
        x -> {
          trace(x);
          return x;
        }
      ).serve();
      return a;
    }
    var b = function(v:String,cont:Terminal<String,Dynamic>):Work{
      var ft  = Future.trigger();
          ft.trigger(__.success(v));
      var snd = cont.later(ft).map(
        x -> {
          trace(x);
          return x;
        }
      );
      var fst = snd.defer(a.receive(1));
      return fst.reply();
    }
    //var c = a(1,Terminal.unit());
    //$type(c);
    //c.toCycle().crunch();
    var d = b("hello",Terminal.unit());
    d.toCycle().crunch();
  }
}