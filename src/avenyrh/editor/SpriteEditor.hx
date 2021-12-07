package avenyrh.editor;

import sys.io.File;
import haxe.ds.StringMap;
import avenyrh.utils.JsonUtils;
import sys.FileSystem;
import avenyrh.imgui.ImGui;

class SpriteEditor extends EditorPanel
{
    var currentImage : String = "";

    var tex : h3d.mat.Texture = null;

    var zoom : Float = 1;

    var mode : SpriteMode = Simple;

    var params : Vector2 = Vector2.ONE;

    var color : h3d.Vector = Color.intToVector(Color.iYELLOW);

    public override function draw(dt : Float)
    {
        flags |= MenuBar;

        //Scene window
        ImGui.begin("Sprite editor", null, flags);

        //Main menu bar
        if(ImGui.beginMenuBar())
        {
            if(ImGui.button('Save##spriteEditor', {x : 100, y : 20}))
                save();

            ImGui.pushStyleColor(Button, Color.rgbaToInt({r : 0, g : 0, b : 0, a : 0}));
            ImGui.pushStyleColor(ButtonHovered, Color.rgbaToInt({r : 0, g : 0, b : 0, a : 0}));
            ImGui.pushStyleColor(ButtonActive, Color.rgbaToInt({r : 0, g : 0, b : 0, a : 0}));
            ImGui.pushStyleColor(Border, Color.rgbaToInt({r : 0, g : 0, b : 0, a : 0}));
            var label : String = currentImage != "" ? currentImage : "Null";
            ImGui.button('$label##spriteEditorButton', {x : 140, y : 20});
            ImGui.popStyleColor(4);

            //Drag drop
            if(ImGui.beginDragDropTarget())
            {
                var path : String = ImGui.acceptDragDropPayloadString(EditorPanel.ddImageContent);
                if(!ImGui.isMouseDown(0))
                {
                    currentImage = path;
                    tex = hxd.Res.load(path).toTexture();

                    //Check if sprite file already exist
                    var p : String = currentImage + ".sprite";
                    if(FileSystem.exists(p))
                    {
                        //Retrieve content
                        var s : String = File.getContent(p);
                        var dyn : haxe.DynamicAccess<Dynamic> = haxe.Json.parse(s);
                        var data : StringMap<Dynamic> = JsonUtils.parseToStringMap(dyn);

                        switch(data.get("Mode"))
                        {
                            case "Simple" : 
                                mode = Simple;
                            case "MultipleBySize" : 
                                mode = MultipleBySize;
                            case "MultipleByNumber" : 
                                mode = MultipleByNumber;
                        }

                        params = new Vector2(data.get("Params X"), data.get("Params Y"));
                    }
                }
    
                ImGui.endDragDropTarget();
            }

            ImGui.sameLine();
            if(ImGui.button("X##spriteEditor", {x : 20, y : 20}))
                currentImage = "";

            //Mode
            ImGui.sameLine(300);
            var index : Int = mode.getIndex();
            var ea : Array<SpriteMode> = haxe.EnumTools.createAll(SpriteMode);
            var naString = new hl.NativeArray<String>(ea.length);
    
            for(i in 0 ... ea.length)
                naString[i] = Std.string(ea[i]);
    
            ImGui.pushItemWidth(150);
            if(ImGui.beginCombo('##spriteEditorMode', naString[index]))
            {
                for(i in 0 ... naString.length)
                {
                    var isSelected : Bool = i == index;
    
                    if(ImGui.selectable(naString[i], isSelected))
                        mode = haxe.EnumTools.createByIndex(SpriteMode, i);
                }
    
                ImGui.endCombo();
            }

            //Params
            if(mode != Simple)
            {
                var naSingle = new hl.NativeArray<Single>(2);
                naSingle[0] = params.x;
                naSingle[1] = params.y;
                if(ImGui.inputFloat2('##spriteEditorParams', naSingle, "%.3f"))
                {
                    params.x = naSingle[0];
                    params.y = naSingle[1];
                }
            }

            //Color
            var na = new hl.NativeArray<Single>(3);
            na[0] = color.r;
            na[1] = color.g;
            na[2] = color.b;
            ImGui.colorEdit3('##spriteEditorColor', na);
            color.r = cast na[0];
            color.g = cast na[1];
            color.b = cast na[2];

            ImGui.popItemWidth();
     
            ImGui.endMenuBar();
        }

        //Image
        if(tex != null)
        {
            var drawList : ImDrawList = ImGui.getForegroundDrawList();
            var avail : Vector2 = ImGui.getContentRegionAvail();
            var size : Vector2 = new Vector2(tex.width, tex.height);
            var center : Vector2 = new Vector2(avail.x / 2, avail.y / 2 + 40);
            var topLeft : Vector2 = new Vector2(center.x - size.x / 2, center.y - size.y / 2);
            ImGui.setCursorPos(topLeft);
            var cursor : Vector2 = ImGui.getCursorScreenPos();
            ImGui.image(tex, {x : size.x * zoom, y : size.y * zoom});

            if(mode != Simple)
            {
                var nbX : Int = mode.match(MultipleBySize) ? AMath.ceil(size.x / params.x) : Std.int(params.x);
                var nbY : Int = mode.match(MultipleBySize) ? AMath.ceil(size.y / params.y) : Std.int(params.y);
                var quadSize : Vector2 = new Vector2(size.x / nbX, size.y / nbY);

                for(x in 0...nbX)
                {
                    for(y in 0...nbY)
                    {
                        var p1 : Vector2 = new Vector2(x * quadSize.x, y * quadSize.y) + cursor;
                        var p2 : Vector2 = new Vector2((x + 1) * quadSize.x, y * quadSize.y) + cursor;
                        var p3 : Vector2 = new Vector2((x + 1) * quadSize.x, (y + 1) * quadSize.y) + cursor;
                        var p4 : Vector2 = new Vector2(x * quadSize.x, (y + 1) * quadSize.y) + cursor;

                        drawList.addQuad(p1, p2, p3, p4, Color.vectorToInt(color));
                    }
                }
            }
        }

        ImGui.end();
    }

    function save()
    {
        var p : String = currentImage + ".sprite";
        if(!FileSystem.exists(p))
        {
            trace("File does not exist : " + p);
        }

        var data : StringMap<Dynamic> = new StringMap();

        data.set("Mode", mode.getName());
        data.set("Params X", params.x);
        data.set("Params Y", params.y);

        JsonUtils.saveJson(p, JsonUtils.stringify(data, Full));
    }
}

enum SpriteMode
{
    Simple;
    MultipleBySize;
    MultipleByNumber;
}