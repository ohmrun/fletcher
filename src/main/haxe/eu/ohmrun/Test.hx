package eu.ohmrun;

import stx.log.Facade;

import eu.ohmrun.test.*;

class Test{
  static public function log(wildcard:Wildcard){
    return new stx.Log().tag("eu.ohmrun.test");
  }
  public function new(){}
}