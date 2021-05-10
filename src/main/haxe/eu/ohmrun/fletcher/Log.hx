package eu.ohmrun.fletcher;

class Log{
  static public function log(wildcard:Wildcard):stx.Log{
    return new stx.Log().tag("eu.ohmrun.fletcher");
  }
}