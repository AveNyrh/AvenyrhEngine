package avenyrh.editor;

import avenyrh.editor.SpriteEditor.SpriteMode;
import avenyrh.utils.JsonUtils;
import sys.io.File;
import sys.FileSystem;
import haxe.io.Path;
import haxe.ds.StringMap;
import avenyrh.imgui.ImGui;

class ContentWindow extends EditorPanel
{
    var currentDir : String = "";

    var arr : Array<String> = [];

    var icons : Array<h3d.mat.Texture> = [];

    var sprites : StringMap<Array<Sprite>> = new StringMap<Array<Sprite>>();

    var seeSprites : Bool = false;

    var buttonSize : Int = 100;

    var tooltipSize : Vector2 = new Vector2(60, 60);

    public var currentSprite : Null<Sprite>;

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

        //Sprite/Image button
        if(ImGui.button(seeSprites ? "Sprite" : "Image", {x : 60, y : 20}))
        {
            seeSprites = !seeSprites;

            if(seeSprites)
                setSprites();
        }

        //Back button
        ImGui.sameLine();
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

        //Text of current directory
        ImGui.sameLine();
        ImGui.text(currentDir);

        //Slider to change icon size
        var windowWidth : Float = cast ImGui.getWindowContentRegionWidth();
        ImGui.sameLine(windowWidth - 240);
        var size = new hl.NativeArray<Int>(1);
        size[0] = buttonSize;
        ImGui.setNextItemWidth(200);
        ImGui.sliderInt("Size", size, 40, 200);
        buttonSize = size[0];

        ImGui.endMenuBar();

        //Calculate number of columns
        var columnNb : Int = cast(windowWidth / (buttonSize + 14));
        columnNb = AMath.imax(columnNb, 1);
        ImGui.columns(columnNb, null, false);

        //Change button's background color 
        ImGui.pushStyleColor2(Button, {x : 1, y : 1, z : 1, w : 0});

        //Content
        arr = FileSystem.readDirectory(currentDir);

        for(entry in arr)
        {
            var e : String = currentDir + "/" + entry;
            var nextColumn : Bool = true;

            if(FileSystem.isDirectory(e))
            {
                //Directory
                ImGui.pushID(e);
                if(ImGui.imageButton(icons[FileIcon.Folder], {x : buttonSize, y : buttonSize}))
                    currentDir = e;

                ImGui.popID();
                ImGui.text(entry);
            }
            else
            {
                switch (Path.extension(e))
                {
                    case "png", "PNG", "jpg" :
                        ImGui.pushID(e);

                        if(seeSprites)
                        {
                            //Sprites
                            var tex : h3d.mat.Texture = hxd.Res.load(getPathFromRes(e)).toTexture();
                            var i : Int = 0;
    
                            for(sprite in sprites.get(e))
                            {
                                ImGui.imageButton(tex, {x : buttonSize, y : buttonSize}, {x : sprite.x, y : sprite.y});
    
                                var prefix : String = sprites.get(e).length == 1 ? "" : Std.string(i++);
        
                                //Drag drop source
                                if(ImGui.beginDragDropSource())
                                {
                                    ImGui.setDragDropPayloadString(EditorPanel.ddSpriteContent, "");
                                    currentSprite = sprite;
        
                                    ImGui.beginTooltip();
                                    ImGui.image(tex, {x : tooltipSize.x, y : tooltipSize.y});
                                    ImGui.endTooltip();
        
                                    ImGui.endDragDropSource();
                                }
                                ImGui.text(entry + prefix);

                                ImGui.nextColumn();
                            }
                            nextColumn = false;
                        }
                        else 
                        {
                            //Images
                            var tex : h3d.mat.Texture = hxd.Res.load(getPathFromRes(e)).toTexture();
                            ImGui.imageButton(tex, {x : buttonSize, y : buttonSize});

                            //Drag drop source
                            if(ImGui.beginDragDropSource())
                            {
                                ImGui.setDragDropPayloadString(EditorPanel.ddImageContent, getPathFromRes(e));
        
                                ImGui.beginTooltip();
                                ImGui.image(tex, {x : tooltipSize.x, y : tooltipSize.y});
                                ImGui.endTooltip();
        
                                ImGui.endDragDropSource();
                            }

                            ImGui.text(entry);
                        }
                        ImGui.popID();

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

            if(nextColumn)
                ImGui.nextColumn();
        }
        ImGui.popStyleColor();
        
        ImGui.end();
    }

    function setSprites()
    {
        sprites = new StringMap<Array<Sprite>>();

        //Content
        arr = FileSystem.readDirectory(currentDir);

        for(entry in arr)
        {
            var e : String = currentDir + "/" + entry;
            var extension : String = Path.extension(e);
            if(extension == "png" || extension == "PNG" || extension == "jpg")
            {
                var p : String = e + ".sprite";

                if(FileSystem.exists(getPathFromRes(p)))
                {
                    //Sprite
                    var spiteArray : Array<Sprite> = [];
                    
                    //Retrieve content
                    var tex : h3d.mat.Texture = hxd.Res.load(getPathFromRes(e)).toTexture();
                    var s : String = File.getContent(getPathFromRes(p));
                    var dyn : haxe.DynamicAccess<Dynamic> = haxe.Json.parse(s);
                    var data : StringMap<Dynamic> = JsonUtils.parseToStringMap(dyn);
                    var params : Vector2;

                    params = new Vector2(data.get("Params X"), data.get("Params Y"));

                    switch(data.get("Mode"))
                    {
                        case "Simple" : 
                            spiteArray.push(new Sprite(getPathFromRes(e)));

                        case "MultipleBySize" : 
                            var x : Float = params.x / tex.width;
                            var y : Float = params.y / tex.height;

                            for(i in 0...Std.int(x))
                            {
                                for(j in 0...Std.int(y))
                                {
                                    spiteArray.push(new Sprite(getPathFromRes(e), i * params.x, j * params.y, params.x, params.y));
                                }
                            }

                        case "MultipleByNumber" : 
                            var width : Float = tex.width / params.x;
                            var height : Float = tex.height / params.y;

                            for(i in 0...Std.int(params.x))
                            {
                                for(j in 0...Std.int(params.y))
                                {
                                    spiteArray.push(new Sprite(getPathFromRes(e), i * width, j * height, width, height));
                                }
                            }
                    }

                    sprites.set(e, spiteArray);
                    trace("Sprites added to " + e);
                }
                else 
                {
                    //Just image
                    var sprite : Sprite = new Sprite(getPathFromRes(e));
                    sprites.set(e, [sprite]);
                }
            }
        }     
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