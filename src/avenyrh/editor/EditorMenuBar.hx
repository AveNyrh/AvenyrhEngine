package avenyrh.editor;

import avenyrh.scene.SceneManager;
import avenyrh.scene.SceneSerializer;
import avenyrh.imgui.ImGui;

class EditorMenuBar extends EditorPanel
{
    var currentItem : String = "";

    //-------------------------------
    //#region Public API
    //-------------------------------
    public override function draw(dt : Float) 
    {
        super.draw(dt);

        ImGui.beginMainMenuBar();

        if(ImGui.beginMenu("File"))
        {
            if(ImGui.menuItem("Save scene", "Ctrl + S"))
            {
                SceneSerializer.serialize(SceneManager.currentScene);
            }

            if(ImGui.menuItem("Exit", "F4"))
            {
                hxd.System.exit();
            }

            ImGui.endMenu();
        }

        ImGui.endMainMenuBar();

        //Shortcuts
        if(hxd.Key.isPressed(hxd.Key.S))
        {
            if(hxd.Key.isDown(hxd.Key.CTRL))
                SceneSerializer.serialize(SceneManager.currentScene);
        }

        if(hxd.Key.isDown(hxd.Key.F4))
            hxd.System.exit();
    }
    //#endregion
}