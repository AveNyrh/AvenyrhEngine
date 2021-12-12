package avenyrh.editor;

import avenyrh.imgui.ImGui;

class AnimationWindow extends  EditorPanel
{
    override function draw(dt:Float) 
    {
        super.draw(dt);

        flags = NoCollapse | MenuBar;

        //Animaion window
        ImGui.begin("Animation window", null, flags);

        //Main menu bar
        if(ImGui.beginMenuBar())
        {
            

            ImGui.endMenuBar();
        }

        

        ImGui.end();
    }
}