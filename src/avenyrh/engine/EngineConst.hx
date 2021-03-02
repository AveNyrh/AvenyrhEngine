package avenyrh.engine;

/**
 * Class that contains all engine constants 
 **/
class EngineConst 
{
  public static var FPS (default, set) : Int = 60;

  //#region Inspector
  public static var INSPECTOR_MAX_HEIGHT (default, null) : Int = 600;
  public static var INSPECTOR_DEFAULT_WIDTH (default, null) : Int = 300;
  public static var INSPECTOR_DEFAULT_HEIGHT (default, null) : Int = 500;

  public static var INSPECTOR_FOLD_WIDTH (default, null) : Int = 280;
  public static var INSPECTOR_FOLD_HEIGHT (default, null) : Int = 30;
  public static var INSPECTOR_FIELD_WIDTH (default, null) : Int = 260;
  public static var INSPECTOR_FIELD_HEIGHT (default, null) : Int = 20;

  public static var INSPECTOR_BG_COLOR (default, null) : Int = 0xFF1c1f24;
  public static var INSPECTOR_FOLD_COLOR (default, null) : Int = 0xFF282c34;
  public static var INSPECTOR_FIELD_COLOR (default, null) : Int = 0xFF404755;
  public static var INSPECTOR_TEXT_COLOR (default, null) : Int = 0xFF7f848e;
  public static var INSPECTOR_TEXT_COLOR_FIELD (default, null) : Int = 0xFF9da2ae;
  public static var INSPECTOR_ICON_ON_COLOR (default, null) : Int = 0xFF9da2ae;
  public static var INSPECTOR_ICON_OFF_COLOR (default, null) : Int = 0xFF282c34;
  //#endregion

  static function set_FPS(fps : Int) : Int
  {
    FPS = fps;
    
    if(onFPSChanged != null)
      onFPSChanged();

    return FPS;
  }

  static var onFPSChanged : Void -> Void;
}