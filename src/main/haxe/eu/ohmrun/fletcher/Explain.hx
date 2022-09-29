package eu.ohmrun.fletcher;

enum abstract Explain(Int){
  final FAILURE = -1; // Oops
  final PENDING = 0;  // Waiting to be called
  final APPLIED = 1;  // Known that the Task requires to be called only once

  final WORKING = 2;  // Something is occurring, don't drop, but don't call either
  final WAITING = 3;  // Requires an asyncronous break, will call back on .signal
}