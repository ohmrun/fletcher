package eu.ohmrun.fletcher.core;

// class BridgeApi<Ri,Rii,E> extends TaskApi<Rii,E> extends WorkApi{
//   final lhs : Task<Ri,E>;
//   var rhs   : Null<Task<Rii,E>>; 

//   public function through_bind(r:TaskReturn<Ri,E>):Task<Rii,E>;
//   public final arrow_type : ArrowType;

// }
// class BridgeCls<Ri,Rii,E> implements BridgeApi<Ri,Rii,E> extends ThroughBind{
//   // public function reply():WorkState{
//   //   switch(rhs){
//   //     case null : react();
//   //     default   : 
//   //       final result = task_progress_to_work_state(rhs.progress);
//   //       switch(result){
//   //         case WorkMore : react();    
//   //         default;
//   //       }
//   //       result;
//   //   }
//   // }
//   private function task_progress_to_work_state(task_progress){
//     return switch(task_progress){
//       case PROBLEM | SECURED  : WorkDone;
// 	    case PENDING | WORKING  : WorkMore;
// 	    case WAITING            : WorkWait; 
//     }
//   }
// }