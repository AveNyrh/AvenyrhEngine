package avenyrh.editor;

import avenyrh.imgui.ImGui.ImGuiWindowFlags;

class EditorPanel
{
    static var Editor : Editor;

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
    //#endregion
}