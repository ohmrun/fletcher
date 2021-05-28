using eu.ohmrun.Fletcher;

using tink.CoreApi;
using stx.Nano;
using stx.unit.Test;
using stx.Fn;

class Main{
  static public function main(){
    // __.unit(
    //   [new ThenTest()],
    //   []
    // );
    new ThenTest().test();
  }
}
class CycleTest extends TestCase{
  public function test(){
    var a = Cycle.unit();
    var b = Cycle.unit();
    a.seq(b).crunch();
  }
}
class ThenTest extends TestCase{
  public function test(){
    var a = Fletcher.Sync((x) -> {
      trace(x);
      return x+1;
    });
    var b = Fletcher.Sync((y) -> {
      trace(y);
      return y+5;
    });
    var c = a.then(b);
        c.environment(
          100,
          (x) -> trace(x)
        ).crunch();
  }
}
// class Test extends TestCase{
//   public function _test(){
    
//     var a = Terminal.unit().issue(__.success(1));
//     // var b = a.apply(
//     //   (v) -> {
//     //     trace(v);
//     //     return Work.unit();
//     //   }
//     // );
//     var a = function(v:Int,cont:Terminal<Int,Dynamic>):Work{
//       var ft = Future.trigger();
//           trace('a called with $v');
//           ft.trigger(__.success(v+1));
//       var a  = cont.later(ft).map(
//         x -> {
//           trace(x);
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
//           trace(x);
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