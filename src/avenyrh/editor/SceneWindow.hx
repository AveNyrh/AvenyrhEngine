package avenyrh.editor;

import avenyrh.imgui.ImGui;

class SceneWindow extends EditorWidget
{
    public override function draw(dt : Float)
    {        
        super.draw(dt);

        //Scene window
        ImGui.begin("Scene");
        
        ImGui.end();
    }
}