package avenyrh.editor;

import avenyrh.imgui.ImGui;

class EditorMenuBar extends EditorWidget
{
    var currentItem : String = "";

    //-------------------------------
    //#region Public API
    //-------------------------------
    public override function draw(dt : Float) 
    {
        super.draw(dt);

        ///*
        ImGui.beginMainMenuBar();

        if(ImGui.beginMenu("Test1"))
        {
            currentItem = "TestItem1";
        }

        if(ImGui.beginMenu("Test2"))
        {
            currentItem = "TestItem2";
        }

        ImGui.endMainMenuBar();
        //*/
    }

    override function close() 
    {
        super.close();

        currentItem = "";
    }
    //#endregion

    //-------------------------------
    //#region Public API
    //-------------------------------
    function showTest1()
    {
        if(ImGui.menuItem("Test1 item1"))
            trace("Test1 item1");

        if(ImGui.menuItem("Test1 item2"))
            trace("Test1 item2");
    }

    function showTest2()
    {
        if(ImGui.menuItem("Test2 item1"))
            trace("Test2 item1");

        if(ImGui.menuItem("Test2 item2"))
            trace("Test2 item2");
    }
    //#endregion
}