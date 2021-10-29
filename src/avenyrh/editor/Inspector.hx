package avenyrh.editor;

import haxe.Int64;
using Lambda;
import haxe.EnumTools;
import avenyrh.imgui.ImGui;
import avenyrh.engine.Scene;
import avenyrh.engine.SceneManager;
import avenyrh.engine.SceneSerializer;
import avenyrh.engine.Uniq;
import h2d.Tile;

class Inspector extends EditorWidget
{
    /**
     * Current object being inspected
     */
    public static var currentInspectable : Null<IInspectable>;

    /**
     * Indent space for the hierarchy
     */
    public static inline var indentSpace : Float = 10;

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

        //Hierarchy window
        ImGui.begin("Hierarchy");

        var scene : Scene = SceneManager.currentScene;

        //Json
        if(ImGui.button("Serialize",  {x : 100, y : 20}))
            SceneSerializer.serialize(scene);

        ImGui.sameLine(110);

        if(ImGui.button("Deserialize",  {x : 100, y : 20}))
            SceneSerializer.deserialize(scene.name);

        //Change this when having another (de)serialize button placement
        scene = SceneManager.currentScene;

        var flags : ImGuiTreeNodeFlags = DefaultOpen;

        ImGui.separator();
        if(ImGui.treeNodeEx("Process", flags))
        {
            ImGui.spacing();
            var i : IInspectable = scene.drawHierarchy();
            if(i != null)
                currentInspectable = i;
            ImGui.treePop();
        }

        ImGui.separator();
        if(ImGui.treeNodeEx("Game", flags))
        {
            for(i in 0 ... @:privateAccess scene.rootGo.children.length)
            {
                ImGui.spacing();
                var insp : IInspectable = @:privateAccess scene.rootGo.children[i].drawHierarchy();

                if(insp != null)
                    currentInspectable = insp;

                ImGui.spacing();
            }
            ImGui.treePop();
        }

        ImGui.separator();
        if(ImGui.treeNodeEx("Misc", flags))
        {
            for(i in scene.miscInspectable)
            {
                ImGui.spacing();

                var insp : IInspectable = i.drawHierarchy();

                if(insp != null)
                    currentInspectable = insp;

                ImGui.spacing();
            }
            ImGui.treePop();
        }

        ImGui.end();

        //Inspector Window
        ImGui.begin("Inspector");

        if(currentInspectable != null)
        {
            if(ImGui.collapsingHeader('${currentInspectable.name}###${currentInspectable.name}${currentInspectable.uID}', DefaultOpen))
            {
                currentInspectable.drawInspector();
            }
        }

        ImGui.end();
    }

    public override function close()
    {
        super.close();

        currentInspectable = null;
    }
    //#endregion

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
                //Atm, just draws the string, not possible to change it
                Inspector.labelText(field.name, u.uID, cast value);
                return value;

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
        ImGui.sameLine(off);
        ImGui.text('$label');
        return v.get();
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