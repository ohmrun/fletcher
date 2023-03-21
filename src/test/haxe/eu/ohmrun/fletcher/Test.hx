package eu.ohmrun.fletcher;

using stx.Log;
using stx.Nano;
using stx.Test;
using stx.Stream;

import eu.ohmrun.test.*;

class Test{
  static function main(){
    __.test().run(
      [new ThenTest()],
      []
    );
    var then_test = new ThenTest();
        then_test.test();
  }  
  public function new(){}
}
class CycleTest extends TestCase{
  public function test(){
    var a = Cycle.unit();
    var b = Cycle.unit();
        a.seq(b).crunch();
  }
}
class ThenTest extends TestCase{
  public function test_env(){
    var a = Fletcher.Sync((x:Int) -> {
      __.log().debug(x);
      return x+1;
    });
    a.environment(
      1,
      (x) -> __.log().debug('$x')
    ).crunch();
    __.log().debug("______");
  }
  public function test(){
    var a = Fletcher.Sync((x:Int) -> {
      __.log().debug(x);
      return x+1;
    });
    var b = Fletcher.Sync((y:Int) -> {
      __.log().debug(y);
      return y*5;
    });
    var c = a.then(b);
        c.environment(
          100,
          (x) -> {
            equals(505,x);
            __.log().debug(x);
          }
        ).crunch();
  }
  public function async_test(async:Async){
    var a = Fletcher.Sync((x:Int) -> {
      __.log().debug(x);
      return x+1;
    });
    var b = Fletcher.Sync((y:Int) -> {
      __.log().debug(y);
      return y*5;
    });
    var c = a.then(b);
        c.environment(
          100,
          (x) -> {
            equals(505,x);
            async.done();
          }
        ).submit();
  }
}
// class Test extends TestCase{
//   public function _test(){
    
//     var a = Terminal.unit().issue(__.success(1));
//     // var b = a.apply(
//     //   (v) -> {
//     //     __.log().debug(v);
//     //     return Work.unit();
//     //   }
//     // );
//     var a = function(v:Int,cont:Terminal<Int,Dynamic>):Work{
//       var ft = Future.trigger();
//           __.log().debug('a called with $v');
//           ft.trigger(__.success(v+1));
//       var a  = cont.later(ft).map(
//         x -> {
//           __.log().debug(x);
//           return x;
//         }
//       ).serve();
//       return a;
//     }
//     var b = function(v:String,cont:Terminal<String,Dynamic>):Work{
//       var ft  = Future.trigger();
//           ft.trigger(__.success(v));
//       var snd = cont.later(ft).map(
//         x -> {
//           __.log().debug(x);
//           return x;
//         }
//       );
//       var fst = snd.defer(a.forward(1));
//       return fst.reply();
//     }
//     //var c = a(1,Terminal.unit());
//     //$type(c);
//     //c.toCycle().crunch();
//     var d = b("hello",Terminal.unit());
//     d.toCycle().crunch();
//   }
// }