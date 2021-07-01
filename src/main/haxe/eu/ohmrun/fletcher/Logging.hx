package eu.ohmrun.fletcher;

class Logging{
  static public function log(wildcard:Wildcard):stx.Log{
    return stx.Log.pkg(__.pkg());
  }
}