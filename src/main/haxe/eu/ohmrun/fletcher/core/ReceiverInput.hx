package eu.ohmrun.fletcher.core;

typedef ReceiverInputDef<R,E> = Future<ArwOut<R,E>>;

/**
 * Represents an input for the `ReceiverSink` continuation.
 */
@:using(eu.ohmrun.fletcher.core.ReceiverInput.ReceiverInputLift)
@:forward abstract ReceiverInput<R,E>(ReceiverInputDef<R,E>) from ReceiverInputDef<R,E> to ReceiverInputDef<R,E>{
  static public var _(default,never) = ReceiverInputLift;
  public function new(self) this = self;
  static public function lift<R,E>(self:ReceiverInputDef<R,E>):ReceiverInput<R,E> return new ReceiverInput(self);


  public function zip<Ri>(that:ReceiverInput<Ri,E>):ReceiverInput<Couple<R,Ri>,E>{
    return this.merge(that.prj(),
      (l,r) -> l.zip(r)
    );
  }
  public function prj():ReceiverInputDef<R,E> return this;
  private var self(get,never):ReceiverInput<R,E>;
  private function get_self():ReceiverInput<R,E> return lift(this);
}
class ReceiverInputLift{
  static public function fold_bind<R,Z,E,EE>(self:ReceiverInput<R,E>,ok:R->ReceiverInput<Z,EE>,no:Defect<E>->ReceiverInput<Z,EE>):ReceiverInput<Z,EE>{
    return self.flatMap(
      (oc) -> oc.fold(ok,no)
    );
  }
  static public function fold_mapp<R,Z,E,EE>(self:ReceiverInput<R,E>,ok:R->ArwOut<Z,EE>,no:Defect<E>->ArwOut<Z,EE>):ReceiverInput<Z,EE>{
    return self.map(
      (oc) -> oc.fold(ok,no)
    );
  }
  static public function map<R,Ri,E>(self:ReceiverInput<R,E>,fn:R->Ri):ReceiverInput<Ri,E>{
    return self.map(
      oc -> oc.map(fn)
    );
  }
}