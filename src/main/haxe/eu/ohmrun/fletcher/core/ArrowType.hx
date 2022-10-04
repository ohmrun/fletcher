package eu.ohmrun.fletcher.core;

enum abstract ArrowType(Int){
  final ArrowTaskUnspecified = 0;
  final ArrowTaskNoop        = 1;
  final ArrowTaskFuture      = 2;
  final ArrowTaskSeq         = 3;
  final ArrowTaskAmb         = 4;
  final ArrowTaskThroughBind = 5;

  final ArrowThen            = 6;

  @:from static public fromTaskType(v:TaskType):ArrowType{
    return switch(v){
      case TaskUnspecified:   ArrowTaskUnspecified;
      case TaskNoop:          ArrowTaskNoop;
      case TaskFuture:        ArrowTaskFuture;
      case TaskSeq:           ArrowTaskSeq;
      case TaskAmb:           ArrowTaskAmb;
      case TaskThroughBind:   ArrowTaskThroughBind;
    }
  } 
}