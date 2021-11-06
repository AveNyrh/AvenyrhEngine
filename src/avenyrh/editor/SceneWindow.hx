package avenyrh.editor;

import avenyrh.imgui.ImGui;
import h3d.mat.Texture;

class SceneWindow extends EditorWidget
{
    public var width (default, null) : Int = 0;

    public var height (default, null) : Int = 0;

    public var sceneTex : Texture = null;

    public override function draw(dt : Float)
    {        
        super.draw(dt);

        flags |= ImGuiWindowFlags.MenuBar | ImGuiWindowFlags.NoBackground;

        //Scene window
        ImGui.begin("Scene", null, flags);

        width = cast ImGui.getWindowWidth();
        height = cast ImGui.getWindowHeight() - 60;

        //Main menu bar
        if(ImGui.beginMenuBar())
        {
            ImGui.text('$width x $height');
        
            ImGui.endMenuBar();
        }

        //Scene image
        ImGui.image(sceneTex, {x : width, y : height});
        
        ImGui.end();
    }
}