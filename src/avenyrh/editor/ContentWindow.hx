package avenyrh.editor;

import h2d.Tile;
import sys.FileSystem;
import haxe.io.Path;
import avenyrh.imgui.ImGui;

class ContentWindow extends EditorWidget
{
    var currentDir : String = "";

    var arr : Array<String> = [];

    var icons : Array<h3d.mat.Texture> = [];

    var buttonSize : Int = 100;

    override function init() 
    {
        currentDir = "examples/res";

        icons.push(hxd.res.Embed.getResource("avenyrh/editor/icons/Default.png").toTexture());
        icons.push(hxd.res.Embed.getResource("avenyrh/editor/icons/Script.png").toTexture());
        icons.push(hxd.res.Embed.getResource("avenyrh/editor/icons/Folder.png").toTexture());
        icons.push(hxd.res.Embed.getResource("avenyrh/editor/icons/Scene.png").toTexture());
    }

    public override function draw(dt : Float)
    {        
        super.draw(dt);

        flags |= MenuBar;

        //Content window
        ImGui.begin("Content", null, flags);

        //Menu bar
        ImGui.beginMenuBar();

        //Back button
        if(ImGui.button("Back", {x : 60, y : 20}))
        {
            var d : Array<String> = currentDir.split("/");

            if(d.length != 1)
            {
                d.pop();
                var p : String = Path.join(d);
                currentDir = p;
            }
        }
        ImGui.sameLine(80);

        //Text of current directory
        ImGui.text(currentDir);
        ImGui.sameLine(300);

        //Slider to change icon size
        var size = new hl.NativeArray<Int>(1);
        size[0] = buttonSize;
        ImGui.sliderInt("Size", size, 40, 200);
        buttonSize = size[0];

        ImGui.endMenuBar();

        //Content
        arr = FileSystem.readDirectory(currentDir);

        //Calculate number of columns
        var spaceLeft : Float = cast ImGui.getWindowContentRegionWidth();
        var columnNb : Int = cast(spaceLeft / (buttonSize + 14));
        columnNb = AMath.imax(columnNb, 1);
        ImGui.columns(columnNb, null, false);

        //Change button's background color 
        ImGui.pushStyleColor2(Button, {x : 1, y : 1, z : 1, w : 0});

        for(entry in arr)
        {
            var e : String = currentDir + "/" + entry;

            if(FileSystem.isDirectory(e))
            {
                //Directory
                ImGui.pushID(e);
                if(ImGui.imageButton(icons[FileIcon.Folder], {x : buttonSize, y : buttonSize}))
                {
                    currentDir = e;
                    trace(e);
                }
                ImGui.popID();
                ImGui.text(entry);
            }
            else
            {
                switch (Path.extension(e))
                {
                    case "png", "PNG", "jpg" :
                        ImGui.pushID(e);
                        if(ImGui.imageButton(hxd.Res.load(getPathFromRes(e)).toTexture(), {x : buttonSize, y : buttonSize}))
                            trace(entry);
                        ImGui.popID();
                        ImGui.text(entry);

                    case "hx" :
                        ImGui.pushID(e);
                        ImGui.imageButton(icons[FileIcon.Script], {x : buttonSize, y : buttonSize});
                        ImGui.popID();
                        ImGui.text(entry);

                    case "scene" :
                        ImGui.pushID(e);
                        ImGui.imageButton(icons[FileIcon.Scene], {x : buttonSize, y : buttonSize});
                        ImGui.popID();
                        ImGui.text(entry);

                    case _ :
                        ImGui.pushID(e);
                        if(ImGui.imageButton(icons[FileIcon.Default], {x : buttonSize, y : buttonSize}))
                            trace(entry);
                        ImGui.popID();
                        ImGui.text(entry);
                }
            }

            ImGui.nextColumn();
        }
        ImGui.popStyleColor();
        
        ImGui.end();
    }

    function getPathFromRes(entry : String)
    {
        var arr : Array<String> = entry.split("/");
        var p : Array<String> = [];

        for(i in 0 ... arr.length - 1)
        {
            if(arr[arr.length - i] == "res")
            {
                return Path.join(p);
            }
            else
            {
                p.insert(0, arr[arr.length - i]);
            }
        }

        return Path.join(p);
    }
}

@:enum abstract FileIcon(Int) from Int to Int 
{
	var Default : Int = 0;
	var Script : Int = 1;
	var Folder : Int = 2;
	var Scene : Int = 3;
}