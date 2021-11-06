package avenyrh.editor;

import avenyrh.imgui.ImGui.ImGuiWindowFlags;

class EditorWidget 
{
    /**
     * Is the widget running
     */
    public var enable (default, null) : Bool;

    var flags : ImGuiWindowFlags = ImGuiWindowFlags.NoCollapse | ImGuiWindowFlags.NoMove;// | ImGuiWindowFlags.NoNav;

    //-------------------------------
    //#region Public API
    //-------------------------------
    public function new()
    {
        enable = true;
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
}