package eu.ohmrun.fletcher;

class Completion<P,R,E> extends FletcherCls<Nada,Nada,Nada>{
  public function new(context,process,?pos:Pos){
    super(pos);
    this.context = context;
    this.process = process;
  }
  public var context(default,null):Context<P,R,E>;
  public var process(default,null):Fletcher<P,R,E>;

  public function defer(p:Nada,cont:Terminal<Nada,Nada>):Work{
    return cont.receive(
      process.forward(this.context.environment).fold_mapp(
        ok -> {
          this.context.on_value(ok);
          return __.success(Nada);
        },
        no -> {
          this.context.on_error(no);
          return __.failure(Defect.unit());
        }
      )
    );
  }
}