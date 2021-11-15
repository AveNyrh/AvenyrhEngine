package avenyrh.editor;

import avenyrh.gameObject.Component;
import avenyrh.gameObject.SpriteComponent;
import avenyrh.engine.Process;
import avenyrh.gameObject.GameObject;
import haxe.Int64;
using Lambda;
import haxe.EnumTools;
import avenyrh.imgui.ImGui;
import avenyrh.scene.Scene;
import avenyrh.scene.SceneManager;
import avenyrh.scene.SceneSerializer;
import avenyrh.engine.Uniq;
import h2d.Tile;

class Inspector extends EditorPanel
{
    /**
     * Current object being inspected
     */
    public static var currentInspectable : Null<IInspectable>;

    /**
     * Indent space for the hierarchy
     */
    public static inline var indentSpace : Float = 6;

    static var fields : Array<String>;
    
    static var rtti : haxe.rtti.CType.Classdef;

    static var textures : Map<h3d.mat.Texture, Int> = [];

    static var off : Int = 226;

    //-------------------------------
    //#region Public API
    //-------------------------------
    public override function draw(dt : Float)
    {        
        super.draw(dt);

        //#region Hierarchy window
        ImGui.begin("Hierarchy", null, flags);

        var scene : Scene = SceneManager.currentScene;

        //Json
        if(ImGui.button("Serialize",  {x : 100, y : 20}))
            SceneSerializer.serialize(scene);

        ImGui.sameLine(110);

        if(ImGui.button("Deserialize",  {x : 100, y : 20}))
            SceneManager.addScene("TestScene");

        //Change this when having another (de)serialize button placement
        scene = SceneManager.currentScene;

        if(scene == null)
        {
            ImGui.end();
            return;
        }

        ImGui.separator();
        ImGui.spacing();

        var treeNodeFlags : ImGuiTreeNodeFlags = DefaultOpen | SpanAvailWidth | OpenOnArrow;

        //Editor camera
        var editorCam : Camera = editor.sceneWindow.camera;
        var camFlags : ImGuiTreeNodeFlags = treeNodeFlags;
        camFlags |= currentInspectable == editorCam ? Selected : 0;

        if(ImGui.treeNodeEx("Editor camera", treeNodeFlags))
            ImGui.treePop();
        

        if(ImGui.isItemClicked())
            currentInspectable = editorCam;

        //Process
        ImGui.spacing();
        if(ImGui.treeNodeEx("Process", treeNodeFlags))
        {
            ImGui.spacing();
            drawHierarchy(scene);
            
            ImGui.treePop();
        }

        ImGui.spacing();
        ImGui.separator();
        ImGui.spacing();
        if(ImGui.treeNodeEx("Game", treeNodeFlags))
        {
            for(i in 0 ... @:privateAccess scene.rootGo.children.length)
            {
                ImGui.spacing();
                drawHierarchy(@:privateAccess scene.rootGo.children[i]);
            }
            ImGui.treePop();
        }

        if(scene.miscInspectable.length > 0)
        {
            ImGui.separator();
            if(ImGui.treeNodeEx("Misc", treeNodeFlags))
            {
                for(i in scene.miscInspectable)
                {
                    ImGui.spacing();
                    drawHierarchy(i);
                }
                ImGui.treePop();
            }
        }

        //Right click on blank space
        if(ImGui.beginPopupContextWindow("Blank space hierarchy context", 1, false))
        {
            addChildGameObjectMenu(scene);
            ImGui.endPopup();
        }

        ImGui.end();
        //#endregion

        //#region Inspector Window
        ImGui.begin("Inspector", null, flags);

        if(currentInspectable != null)
        {
            ImGui.separator();
            currentInspectable.drawInspector();

            //Handle gameObject specific inspector
            if(Std.isOfType(currentInspectable, GameObject))
            {
                //Right click on blank space
                if(ImGui.beginPopupContextWindow("Blank space inspector context", 1, false))
                {
                    //Components that are always present
                    if(ImGui.menuItem("Add SpriteComponent"))
                    {
                        var go : GameObject = cast currentInspectable;
                        go.addComponent(new SpriteComponent("SpriteComponent"));
                    }

                    //Add all custom components dynamicaly
                    ImGui.separator();
                    for(key => value in @:privateAccess editor.data.components) //key = componentName, value = componentClass
                    {
                        if(ImGui.menuItem('Add $key'))
                        {
                            var go : GameObject = cast currentInspectable;
                            go.addComponent(cast Type.createInstance(value, [key]));
                        }
                    }

                    ImGui.endPopup();
                }
            }
        }

        ImGui.end();
        //#endregion
    }

    public override function close()
    {
        super.close();

        currentInspectable = null;
    }
    //#endregion

    function drawHierarchy(inspectable : IInspectable)
    {
        var name : String = "";
        var uID : String = "";
        var children : Array<Dynamic> = [];

        if(Std.isOfType(inspectable, GameObject))
        {
            var go : GameObject = cast inspectable;
            name = go.name;
            uID = Int64.toStr(go.uID);
            children = cast go.children;
        }
        else if(Std.isOfType(inspectable, Process))
        {
            var proc : Process = cast inspectable;
            name = proc.name;
            uID = Int64.toStr(proc.uID);
            children = cast proc.children;
        }

        ImGui.indent(Inspector.indentSpace);

        var treeNodeFlags : ImGuiTreeNodeFlags = OpenOnArrow | DefaultOpen | SpanAvailWidth;
        if(Inspector.currentInspectable == inspectable)
            treeNodeFlags |= Selected;

        var open : Bool = ImGui.treeNodeEx('$name###$name$uID', treeNodeFlags);

        if(ImGui.isItemClicked())
            currentInspectable = inspectable;

        if(ImGui.beginPopupContextWindow('HierarchyItemSettings##$uID'))
        {
            if(Std.isOfType(inspectable, GameObject))
            {
                var go : GameObject = cast inspectable;

                if(ImGui.menuItem("Destroy GameObject"))
                    go.destroy();

                
                ImGui.separator();
                var child = addChildGameObjectMenu(SceneManager.currentScene);
                if(child != null)
                    go.addChild(child);
            }
            else if(Std.isOfType(inspectable, Process))
            {
                var proc : Process = cast inspectable;

                if(ImGui.menuItem("Destroy process"))
                {
                    proc.destroy();
                }
            }
            ImGui.endPopup();
        }

        if(open)
        {   
            for(c in children)
                drawHierarchy(cast c);

            ImGui.treePop();
        }

        ImGui.unindent(Inspector.indentSpace);
    }

    function addChildGameObjectMenu(scene : Scene) : Null<GameObject>
    {
        var go : GameObject = null;
        if(ImGui.menuItem("New Empty GameObject"))
            go = new GameObject("New GameObject", null, scene);

        ImGui.separator();

        for(key => value in @:privateAccess editor.data.gameObjects) //key = menu item, value = class
        {
            if(ImGui.menuItem('New $key'))
                go = cast Type.createInstance(value, [key, null, scene]);
        }

        if(go != null)
            scene.addGameObject(go);

        return go;
    }

    //-------------------------------
    //#region Static API
    //-------------------------------
    /**
     * Draws the parameter fields on the Inspector
     */
    public static function drawInInspector(u : Uniq) 
    {
        fields = Reflect.fields(u);
        rtti = haxe.rtti.Rtti.getRtti(Type.getClass(u));

        for(f in rtti.fields)
        {
            if(f.isPublic && !f.meta.exists(m -> m.name == "hideInInspector") || f.meta.exists(m -> m.name == "serializable"))
            {
                if(fields.contains(f.name))
                {
                    var d : Dynamic = Inspector.drawField(u, f, Reflect.getProperty(u, f.name));

                    if(d != null)
                        Reflect.setProperty(u, f.name, d);
                }
            }
        }
    }

    public static function drawComponent(component : Component)
    {
        var availableSpace : ImVec2 = ImGui.getContentRegionAvail();
        var flags : ImGuiTreeNodeFlags = DefaultOpen | SpanAvailWidth | AllowItemOverlap;
        var open : Bool = ImGui.collapsingHeader('${component.name}###${component.name}${component.uID}', flags);

        var buttonSize : Int = 19; 
        ImGui.sameLine(availableSpace.x - buttonSize / 2 + 4);
        if(ImGui.button('+##${component.uID}', {x : buttonSize, y : buttonSize}))
            ImGui.openPopup('ComponentSettings##${component.uID}');

        ImGui.spacing();
        if(open)
            @:privateAccess component.drawInfo();

        //Pop up for the "+" button
        var removeComponent : Bool = false;
        if(ImGui.beginPopup('ComponentSettings##${component.uID}'))
        {
            if(ImGui.menuItem("Remove component"))
                removeComponent = true;

            ImGui.endPopup();
        }

        if(removeComponent)
            component.gameObject.removeComponent(component);
    }

    static var fv : Array<Float>;
    static var minf : Float;
    static var maxf : Float;
    static var iv : Array<Int>;
    static var mini : Int;
    static var maxi : Int;
    static var vec2 : Vector2;
    static var tile : Tile;
    static var ev : EnumValue;
    static var e : Enum<Dynamic>;
    static var index : Int = 0;

    public static function drawField<T>(u : Uniq, field : haxe.rtti.CType.ClassField, value : Dynamic) : Dynamic
    {
        switch (field.type)
        {
            case CAbstract("Float", []) : //Float
                fv = [cast value];

                if(field.meta.exists(m -> m.name == "range"))
                {
                    minf = Std.parseFloat(field.meta.find(m -> m.name == "range").params[0]);
                    maxf = Std.parseFloat(field.meta.find(m -> m.name == "range").params[1]);
                    Inspector.sliderFloats(field.name, u.uID, fv, minf, maxf);
                }
                else
                    Inspector.dragFloats(field.name, u.uID, fv, 0.1);

                return cast fv[0];

            case CAbstract("Int", []) : //Int
                iv = [cast value];

                if(field.meta.exists(m -> m.name == "range"))
                {
                    mini = Std.parseInt(field.meta.find(m -> m.name == "range").params[0]);
                    maxi = Std.parseInt(field.meta.find(m -> m.name == "range").params[1]);
                    Inspector.sliderInts(field.name, u.uID, iv, mini, maxi);
                }
                else
                    Inspector.dragInts(field.name, u.uID, iv);

                return cast iv[0];

            case CAbstract("Bool", []) : //Bool
                return cast Inspector.checkbox(field.name, u.uID, cast value);

            case CClass("String", []) : //String
                return Inspector.inputText(field.name, u.uID, cast value);

            case CEnum(_, []) : //Enum
                ev = cast Reflect.getProperty(u, field.name);
                e = Type.getEnum(ev);
                index = Inspector.enumDropdown(field.name, u.uID, e, ev.getIndex());
                return EnumTools.createByIndex(e, index);

            case CAbstract("avenyrh.Vector2", []) : //Vector2
                vec2 = Reflect.getProperty(u, field.name);
                fv = [vec2.x, vec2.y];
                Inspector.dragFloats(field.name, u.uID, fv, 0.1);
                vec2 = new Vector2(fv[0], fv[1]);
                return vec2;

            case CClass("h2d.Tile", []) : //Tile
                tile = cast(Reflect.getProperty(u, field.name), Tile);
                Inspector.image(field.name, tile);
                return tile;

            default :
                return null;
        }
    }

    /**
     * Returns true if one of the values has changed
     */
    public static function dragFloats(label : String, id : Int64, data : Array<Float>, step : Float = 1, format : String = "%.3f") : Bool
    {
        var na = new hl.NativeArray<Single>(data.length);
        var changed : Bool = false;

        for(i in 0 ... data.length)
            na[i] = data[i];

        if(ImGui.dragFloat('$label###$label$id', na, step, format))
        {
            changed = true;
            for(i in 0 ... data.length)
                data[i] = na[i];
        }

        return changed;
    }

    /**
     * Returns true if one of the values has changed
     */
    public static function sliderFloats(label : String, id : Int64, data : Array<Float>, min : Float, max : Float, format : String = "%.3f") : Bool
    {
        var na = new hl.NativeArray<Single>(data.length);
        var changed : Bool = false;

        for(i in 0 ... data.length)
            na[i] = data[i];

        if(ImGui.sliderFloat('$label###$label$id', na, min, max, format))
        {
            changed = true;
            for(i in 0 ... data.length)
                data[i] = na[i];
        }

        return changed;
    }

    /**
     * Returns true if one of the values has changed
     */
    public static function dragInts(label : String, id : Int64, data : Array<Int>, step : Float = 1) : Bool
    {
        var na = new hl.NativeArray<Int>(data.length);
        var changed : Bool = false;

        for(i in 0 ... data.length)
            na[i] = data[i];

        if(ImGui.dragInt('$label###$label$id', na, step))
        {
            changed = true;
            for(i in 0 ... data.length)
                data[i] = na[i];
        }

        return changed;
    }

    /**
     * Returns true if one of the values has changed
     */
    public static function sliderInts(label : String, id : Int64, data : Array<Int>, min : Int, max : Int) : Bool
    {
        var na = new hl.NativeArray<Int>(data.length);
        var changed : Bool = false;

        for(i in 0 ... data.length)
            na[i] = data[i];

        if(ImGui.sliderInt('$label###$label$id', na, min, max))
        {
            changed = true;
            for(i in 0 ... data.length)
                data[i] = na[i];
        }

        return changed;
    }

    /**
     * Returns the index of the selected enum value
     */
    public static function enumDropdown<T>(label : String, id : Int64, e : Enum<T>, index : Int, maxItemShown : Int = 4) : Int
    {
        var changed : Bool = false;
        var ea : Array<T> = haxe.EnumTools.createAll(e);
        var na = new hl.NativeArray<String>(ea.length);

        for(i in 0 ... ea.length)
            na[i] = Std.string(ea[i]);

        if(ImGui.beginCombo('$label###$label$id', na[index]))
        {
            for(i in 0 ... na.length)
            {
                var isSelected : Bool = i == index;

                if(ImGui.selectable(na[i], isSelected))
                {
                    index = i;
                    changed = true;
                }
            }

            ImGui.endCombo();
        }

        return index;
    }

    public static function button(label : String, id : Int64) : Bool
    {
        return ImGui.button('$label###$label$id', {x : 200, y : 20});
    }

    /**
     * Returns the value of the checkbox
     */
    public static function checkbox(label : String, id : Int64, value : Bool)  : Bool
    {
        var v : hl.Ref<Bool> = cast value;
        ImGui.checkbox("", v);
        ImGui.sameLine(off + 75);
        ImGui.text('$label');
        return v.get();
    }

    public static function inputText(label : String, id : Int64, text : String) : String
    {
        var input_text_buffer = new hl.Bytes(128);
        input_text_buffer = @:privateAccess text.toUtf8();

        if (ImGui.inputText('$label###$label$id', input_text_buffer, 128)) 
        {
            var st = @:privateAccess String.fromUTF8(input_text_buffer);
            text = st;
        }

        return text;
    }

    public static function labelText(label : String, id : Int64, text : String) 
    {
        ImGui.labelText('$label###$label$id', text);
    }

    public static function image(label : String, tile : Tile) @:privateAccess
    {
        ImGui.image(tile.getTexture(), {x : tile.width, y : tile.height}, {x : tile.u, y : tile.v}, {x : tile.u2, y : tile.v2});
        ImGui.sameLine(off);
        ImGui.text('$label');
    }
    //#endregion
}