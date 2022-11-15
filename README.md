# Fletcher

Fletcher is an effect system and integrated scheduler based on how [arrowlets](https://www.cs.umd.edu/~mwh/papers/jsarrows.pdf) relate to the logical equivalency of threads and events.

A `Fletcher` is a constructor for a continuation monad constrained to return work for a scheduler. (literally `Work`)

Both the input value, the output value and the continuation monad are available to access with a comprehensive set of combinators which allow any combination of synchronous and asynchonous programs to
be connected in ways as powerful as a monad but without the type system requirements.

Topics regarding interleaving functions and values over data streams and between processes are taken on in [stx_coroutine](https://github.com/ohmrun/stx_coroutine) and [stx_proxy](https://github.com/ohmrun/stx_proxy) which rely on this library for their cross platform async support.

```haxe
  using eu.ohmrun.Fletcher;
  class Main{
    static public function main(){
      //lift a function 
      final arr = Fletcher.Sync((i:Int) -> i + 1);
      //provide it's environment
      __.ctx(
        10,//input value
        x -> trace(x),//called on success with result
        e -> throw(e)//called on failure
      ).load(arr)//creates a `Fiber` to be sent to a scheduler
       .submit();//send to the asynchronous scheduler. Can use `crunch` to try and yield a value synchronously
    }
  }
```
