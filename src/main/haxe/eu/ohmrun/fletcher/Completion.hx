package eu.ohmrun.fletcher;

class Completion<P,R,E> extends FletcherCls<Noise,Noise,Noise>{
  public function new(context,process){
    super();
    this.context = context;
    this.process = process;
  }
  public var context(default,null):Context<P,R,E>;
  public var process(default,null):Fletcher<P,R,E>;

  public function defer(p:Noise,cont:Terminal<Noise,Noise>):Work{
    return cont.receive(
      process.forward(this.context.environment).fold_mapp(
        ok -> {
          this.context.on_value(ok);
          return __.success(Noise);
        },
        no -> {
          this.context.on_error(no);
          return __.failure(Defect.unit());
        }
      )
    );
  }
}