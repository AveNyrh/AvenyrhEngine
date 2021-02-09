package avenyrh.engine;

/**
 * Class that contains all engine constants 
 **/
class EngineConst 
{
  public static var FPS (default, set) : Int = 60;

  //Inspector
  public static var INSPECTOR_MAX_WIDTH (default, null) : Int = 300;
  public static var INSPECTOR_MAX_HEIGHT (default, null) : Int = 600;
  public static var INSPECTOR_DEFAULT_WIDTH (default, null) : Int = 200;
  public static var INSPECTOR_DEFAULT_HEIGHT (default, null) : Int = 400;

  static function set_FPS(fps : Int) : Int
  {
    FPS = fps;
    
    if(onFPSChanged != null)
      onFPSChanged();

    return FPS;
  }

  static var onFPSChanged : Void -> Void;
}