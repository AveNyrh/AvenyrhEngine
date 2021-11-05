package avenyrh.editor;

import avenyrh.imgui.ImGui;
import avenyrh.imgui.ImGuiDrawable;
import avenyrh.engine.Process;

class Editor extends Process
{
    var enable : Bool = true;

    var drawable : ImGuiDrawable;

    var menuBar : EditorWidget;

    var inspector : EditorWidget;

    var sceneWindow : EditorWidget;

    var contentWindow : EditorWidget;

    override public function new() 
    {
        super("Editor");

        createRoot(Process.S2D, 10);
        drawable = new ImGuiDrawable(root);

        ImGui.loadIniSettingsFromDisk("default.ini");
        ImGui.setConfigFlags(ImGuiConfigFlags.DockingEnable);

        menuBar = new EditorMenuBar();
        inspector = new Inspector();
        sceneWindow = new SceneWindow();
        contentWindow = new ContentWindow();
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

        var windowFlags : ImGuiWindowFlags = ImGuiWindowFlags.NoCollapse | ImGuiWindowFlags.NoResize | ImGuiWindowFlags.NoMove | ImGuiWindowFlags.NoBackground;
        windowFlags |= ImGuiWindowFlags.NoBringToFrontOnFocus | ImGuiWindowFlags.NoNavFocus;
        ImGui.begin("Dockspace window", null, windowFlags);
        var id : Int = ImGui.getID("Dockspace");
        var dockFlags : ImGuiDockNodeFlags = ImGuiDockNodeFlags.None;
        ImGui.dockSpace(id, {x : 0, y : 0}, dockFlags);

        //ImGui.showDemoWindow();

        menuBar.draw(dt);
        inspector.draw(dt);
        sceneWindow.draw(dt);
        contentWindow.draw(dt);

        ImGui.end();
        ImGui.render();
        ImGui.endFrame();
    }
    //#endregion
}