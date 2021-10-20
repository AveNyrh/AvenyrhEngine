package avenyrh.editor;

import avenyrh.imgui.ImGui;
import avenyrh.imgui.ImGuiDrawable;
import avenyrh.engine.Process;

class Editor extends Process
{
    var enable : Bool;

    var drawable : ImGuiDrawable;

    var menuBar : EditorWidget;

    var inspector : EditorWidget;

    override public function new() 
    {
        super("Editor");

        enable = true;

        createRoot(Process.S2D, 10);
        drawable = new ImGuiDrawable(root);

        ImGui.loadIniSettingsFromDisk("default.ini");
        ImGui.setConfigFlags(ImGuiConfigFlags.DockingEnable);

        menuBar = new EditorMenuBar();
        inspector = new Inspector();
    }

    //-------------------------------
    //#region Private API
    //-------------------------------
    override function update(dt : Float) 
    {
        super.update(dt);

        if(hxd.Key.isPressed(hxd.Key.F4))
            inspector.enable ? inspector.close() : inspector.open();
    }

    override function postUpdate(dt : Float) 
    {
        super.postUpdate(dt);

        if(!enable)
            return;

        draw(dt);
    }

    function draw(dt : Float)
    {
        drawable.update(dt);

        ImGui.newFrame();

        //ImGui.showDemoWindow();

        menuBar.draw(dt);
        inspector.draw(dt);

        ImGui.render();
        ImGui.endFrame();
    }
    //#endregion
}