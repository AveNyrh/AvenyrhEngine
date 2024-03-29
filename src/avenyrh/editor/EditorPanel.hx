package avenyrh.editor;

import avenyrh.imgui.ImGui;
import avenyrh.imgui.ImGui.ImGuiWindowFlags;

class EditorPanel
{
    static var Editor : Editor;

    static var ddGameObjectInspector : String = "DD GameObject Inspector";

    static var ddProcessInspector : String = "DD Process Inspector";

    static var ddImageContent : String = "DD Sprite Content";

    static var ddSpriteContent : String = "DD Sprite Content";

    var isFocused (get, null) : Bool;

    var isAppearing (get, null) : Bool;

    /**
     * Is the widget running
     */
    public var enable (default, null) : Bool;

    var editor (get, null) : Editor;

    var flags : ImGuiWindowFlags = NoCollapse | NoMove;

    //-------------------------------
    //#region Public API
    //-------------------------------
    public function new()
    {
        enable = true;

        init();
    }

    public function draw(dt : Float)
    {
        if(!enable)
            return;
    }

    public function open()
    {
        enable = true;
    }

    public function close()
    {
        enable = false;
    }
    //#endregion

    //-------------------------------
    //#region Overridable functions
    //-------------------------------
    function init() { }
    //#endregion

    //-------------------------------
    //#region Getters & Setters
    //-------------------------------
    function get_editor() : Editor {return EditorPanel.Editor;}

    function get_isFocused() : Bool {return ImGui.isWindowFocused(None);}

    function get_isAppearing() : Bool {return ImGui.isWindowAppearing();}
    //#endregion
}