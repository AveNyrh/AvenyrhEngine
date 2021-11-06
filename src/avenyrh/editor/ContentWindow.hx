package avenyrh.editor;

import avenyrh.imgui.ImGui;

class ContentWindow extends EditorWidget
{
    public override function draw(dt : Float)
    {        
        super.draw(dt);

        //Content window
        ImGui.begin("Content", null, flags);
        
        ImGui.end();
    }
}