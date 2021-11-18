package avenyrh.scene;

import h2d.Bitmap;
import h2d.Tile;
using Lambda;
import haxe.Int64;
import avenyrh.engine.Uniq;
import avenyrh.engine.Process;
import avenyrh.gameObject.Component;
import avenyrh.gameObject.GameObject;
import avenyrh.utils.JsonUtils;
import haxe.ds.StringMap;
import sys.io.File;

class SceneSerializer 
{
    static inline var space : String = " ";
    
    static inline var tab : String = "\t";

    static inline var lineBreak : String = "\n";

    static inline var underscore : String = "_";

    public static var path : String = "res/scenes/";

    static var map : StringMap<Dynamic>;

    static var rtti : haxe.rtti.CType.Classdef;

    static var dummy : GameObject;

    //-------------------------------
    //#region Public static API
    //-------------------------------
    public static function serialize(scene : Scene) @:privateAccess
    {
        var data : StringMap<Dynamic> = new StringMap();

        //Scene
        data.set("Scene", addObject(scene));

        //Camera
        data.set("Camera", addObject(scene.camera));

        //Add gameObjects, components ...
        var gameObjects : Array<StringMap<Dynamic>> = [];
        var components : Array<StringMap<Dynamic>> = [];

        for(go in scene.allGO)
        {
            //Add gameObject
            gameObjects.push(addObject(go));

            //Add each component of this gameObject
            for(c in go.components)
                components.push(addObject(c));
        }

        //Add gameObjects and components data
        data.set("GameObjects", gameObjects);
        data.set("Components", components);

        //Write data
        var p : String = path + scene.name + ".scene";        
        JsonUtils.saveJson(p, JsonUtils.stringify(data, Full));
    }

    /**
     * Deserialize the scene with the name in parameter and adds it to the SceneManager
     * 
     * To do :
     *  - Deserialize process children
     */
    public static function deserialize(name : String) : Scene @:privateAccess
    {
        map = new StringMap<Dynamic>();

        //Retrieve content
        var p : String = path + name + ".scene";
        var s : String = File.getContent(p);
        var dyn : haxe.DynamicAccess<Dynamic> = haxe.Json.parse(s);
        var data : StringMap<haxe.DynamicAccess<Dynamic>> = JsonUtils.parseToStringMap(dyn);

        //------ Scene ------
        //Retrieve scene specific data
        var d : StringMap<Dynamic> = JsonUtils.parseToStringMap(data.get("Scene"));

        //Build a scene class from string
        var c : Class<Dynamic> = Type.resolveClass(d.get("s_classPath"));
        var scene : Scene = cast Type.createInstance(c, [d.get("s_name")]);

        //Add scroller manually
        scene.scroller = new h2d.Layers();
        scene.root.add(scene.scroller, 0);

        //Add scene to the uniqMap
        map.set(d.get("u_uID"), {inst : scene, data : d});

        //------ Hierarchy ------
        //Build the hierarchy with "empty" gameObjects and components
        var children : StringMap<Dynamic> = JsonUtils.parseToStringMap(d.get("a_rootGO"));
        var goData : Array<Dynamic> = cast data.get("GameObjects");
        var goMap : StringMap<StringMap<Dynamic>> = new StringMap<StringMap<Dynamic>>();
        for(go in goData)
        {
            d = JsonUtils.parseToStringMap(go);
            goMap.set(d.get("u_uID"), d);
        }
        var compData : Array<Dynamic> = cast data.get("Components");
        var compMap : StringMap<StringMap<Dynamic>> = new StringMap<StringMap<Dynamic>>();
        for(comp in compData)
        {
            d = JsonUtils.parseToStringMap(comp);
            compMap.set(d.get("u_uID"), d);
        }

        //Create the hierarchy by creating each children recursively
        dummy = new GameObject("Dummy", null, scene);
        for(k => v in children) //k = g_index, v = child uID
        {
            var value : Array<String> = k.split(underscore);
            var index : String = value[1];

            var goInst : GameObject = createGameObject(goMap, v, compMap, scene);
            goInst.parent = null;
        }
        scene.rootGO.remove(dummy);
        scene.allGO.remove(dummy);

        //------ Camera ------
        d = JsonUtils.parseToStringMap(data.get("Camera"));
        c = Type.resolveClass(d.get("s_classPath"));
        var camera : Camera = cast Type.createInstance(c, [d.get("s_name"), scene]);
        map.set(d.get("u_uID"), {inst : camera, data : d});

        //Add this camera to the scene
        scene.children = [];
        scene.children.push(camera);
        scene.camera = camera;

        //------ Fields ------
        //Fill the all the fields of each instance
        for(k => v in map) //k = uID, v = {instance, dataMap}
        {
            var instAndData : InstAndData = cast v;
            setInstanceFields(instAndData.inst, instAndData.data);
        }

        trace('${scene.name} deserialized');

        return scene;
    }
    //#endregion

    //-------------------------------
    //#region Private static API
    //-------------------------------
    static function addObject(object : Dynamic, ?newObject : Bool = true, ?currentClass : Null<Class<Dynamic>> = null) : StringMap<Dynamic>
    {
        //If it's a new object, add necessary data
        if(newObject)
        {
            map = new StringMap<Dynamic>();
            addValue("classPath", getClassPath(object), map);
        }

        if(currentClass != null)
            rtti = haxe.rtti.Rtti.getRtti(currentClass);
        else
            rtti = haxe.rtti.Rtti.getRtti(Type.getClass(object));

        //Add fields
        for(f in rtti.fields)
        {
            if((f.isPublic || f.meta.exists(m -> m.name == "serializable")) && !f.meta.exists(m -> m.name == "noSerial") && f.type.getName() != "CFunction")
            {
                addValue(f.name, Reflect.getProperty(object, f.name), map);
            }
        }

        //Add superClass info
        if(rtti.superClass.path != null && Std.string(currentClass) != Std.string(Uniq))
            addObject(object, false, Type.resolveClass(rtti.superClass.path));

        return map;
    }

    /**
     * Adds a value to the map to insert into the Json
     * Value is like this -> prefix_name : value
     * Prefixes :
     * a : array
     * b : bool
     * c : component
     * e : enum
     * f : float
     * g : gameObject
     * i : int
     * n : null
     * p : process
     * s : string
     * t : tile
     * u : uID
     * bm : bitmap
     * v2 : Vector2
     */
    static function addValue(name : String, value : Dynamic, map : StringMap<Dynamic>)
    {
        //Handle uID here, problem with Int64 class type in the switch
        if(name == "uID")
        {
            map.set('u_$name', Int64.toStr(value));
            return;
        }

        switch Type.typeof(value) 
        {
            case TNull :                        //All null value
                map.set('n_$name', null);

            case TInt :                         //Int
                map.set('i_$name', value);

            case TBool :                        //Bool
                map.set('b_$name', value);

            case TFloat :                       //Float
                map.set('f_$name', value);

            case TClass(String) :               //String
                map.set('s_$name', value);

            case TClass(Array) :                //Array
                var m : StringMap<Dynamic> = new StringMap<Dynamic>();
                var arr : Array<Dynamic> = cast value;

                for(i in 0 ... arr.length)
                    addValue('$i', arr[i], m);

                map.set('a_$name', m);

            case TEnum(e) :                     //Enum
                map.set('e_$name', value);

            case TClass(h2d.Tile) :             //h2d.Tile
                var tile : Tile = cast value;
                var m : StringMap<Dynamic> = new StringMap<Dynamic>();
                //Set tile specific data
                m.set("f_dx", tile.dx);
                m.set("f_dy", tile.dy);
                m.set("f_width", tile.width);
                m.set("f_height", tile.height);
                m.set("f_xFlip", tile.xFlip);
                m.set("f_yFlip", tile.yFlip);             

            //TO DO : Maps

            case _:
                //Forced to test via Std.isOfType because the Type.typeOf returns the top class, 
                //which might not be simply TClass(GameObject) or else
                if(Std.isOfType(value, GameObject))         //GameObject
                {
                    var go : GameObject = cast value;
                    map.set('g_$name', Int64.toStr(go.uID));
                }
                else if(Std.isOfType(value, Component))     //Component
                {
                    var comp : Component = cast value;
                    map.set('c_$name', Int64.toStr(comp.uID));
                }
                else if(Std.isOfType(value, Process))       //Process
                {
                    var proc : Process = cast value;
                    map.set('p_$name', Int64.toStr(proc.uID));
                }
                else if(rtti.fields.find(f -> f.name == name).type.match(CAbstract("avenyrh.Vector2", []))) //Vector2
                {
                    var v : Vector2 = cast value;
                    map.set('v2_$name', [v.x, v.y]);
                }
                else 
                    trace('Unknown value type $name = $value (' + Type.typeof(value) + ')');
        }
    }

    /**
     * Create a gameObject and it's components
     * 
     * Create each of it's children recursively
     */
    static function createGameObject(goMap : StringMap<StringMap<Dynamic>>, uID : String, compMap : StringMap<StringMap<Dynamic>>, scene : Scene) : GameObject
    {
        //Create new gameObject instance
        var d : StringMap<Dynamic> = goMap.get(uID);
        var c : Class<Dynamic> = Type.resolveClass(d.get("s_classPath"));
        var goInst : GameObject = cast Type.createInstance(c, [d.get("s_name"), dummy, scene, Int64.parseString(d.get("u_uID"))]);

        //Add the new gameObject to the uniqMap
        map.set(d.get("u_uID"), {inst : goInst, data : d});

        //Add components
        var components : StringMap<Dynamic> = JsonUtils.parseToStringMap(d.get("a_components"));
        for(k => v in components) //k = c_index, v = component uID
        {
            var value : Array<String> = k.split(underscore);
            var index : String = value[1];

            //Create new component instance
            d = compMap.get(v);
            c = Type.resolveClass(d.get("s_classPath"));
            var compInst : Component = cast Type.createInstance(c, [d.get("s_name"), Int64.parseString(d.get("u_uID"))]);

            //Add the new component to the uniqMap
            map.set(d.get("u_uID"), {inst : compInst, data : d});

            //Add this component to its gameObject
            @:privateAccess goInst.components.insert(Std.parseInt(index), compInst);
            compInst.gameObject = goInst;
        }
        
        //Create children recursively
        var children : StringMap<Dynamic> = JsonUtils.parseToStringMap(goMap.get(uID).get("a_children"));
        for(k => v in children) //k = g_index, v = child uID
        {
            var value : Array<String> = k.split(underscore);
            var index : String = value[1];

            var goInst : GameObject = createGameObject(goMap, v, compMap, scene);
            goInst.children.insert(Std.parseInt(index), goInst);
            goInst.parent = goInst;
        }

        return goInst;
    }

    static function setInstanceFields(inst : Dynamic, dataMap : StringMap<Dynamic>)
    {
        var uID : String = dataMap.get("u_uID");
        var fields : Array<String> = Type.getClassFields(inst);

        for(key => value in dataMap) //key = type_fieldName, value = fieldValue
        {
            //Avoid to set hierarchy fields
            if(Std.isOfType(inst, GameObject) && key == "a_children" || Std.isOfType(inst, GameObject) && key == "a_components" || //GameObjects fields
                Std.isOfType(inst, Component) && key == "g_gameObject" || //Components fields
                Std.isOfType(inst, Process) && key == "a_children") //Process fields
                continue;

            var arr : Array<String> = key.split(underscore);
            var type : String = arr[0];
            var fieldName : String = arr[1];

            if(!fields.contains(fieldName))
                continue;

            switch (type)
            {
                case "n" : //Null
                    Reflect.setField(inst, fieldName, null);

                case "f", "i", "s", "b" : //Float, int, string, bool
                    Reflect.setField(inst, fieldName, dataMap.get(key));

                case "e": //Enum
                    var ev : EnumValue = cast Reflect.getProperty(inst, fieldName);
                    var e : Enum<Dynamic> = Type.getEnum(ev);
                    ev = e.createByName(value);
                    Reflect.setField(inst, fieldName, Type.createEnumIndex(e, ev.getIndex()));

                case "g" : //GameObject
                    var instAndData : InstAndData = cast map.get(value);
                    Reflect.setField(inst, fieldName, instAndData.inst);

                case "c" : //Component
                    var instAndData : InstAndData = cast map.get(value);
                    Reflect.setField(inst, fieldName, instAndData.inst);
                
                case "u" : //UID
                    Reflect.setField(inst, fieldName, Int64.parseString(dataMap.get(key)));

                case "a" : //Array
                    Reflect.setField(inst, fieldName, getArray(key, value));

                case "v2" : //Vector2
                    var v : Array<Float> = cast value;
                    Reflect.setField(inst, fieldName, new Vector2(v[0], v[1]));

                case _ :
                    trace('Deserialization not supported for ${fieldName}');
            }
        }
    }

    static function getArray(key : String, value : Dynamic) : Array<Dynamic>
    {
        var fieldName : String = key.split(underscore)[1];
        var arr : Array<Dynamic> = [];
        var m : StringMap<Dynamic> = JsonUtils.parseToStringMap(value);
        var type : String = "";
        var index : Int = -1;

        for(k => v in m) //k = type_index, v = fieldValue
        {
            type = k.split(underscore)[0];
            index = Std.parseInt(k.split(underscore)[1]);

            switch (type)
            {
                case "f", "i", "s", "b" : //float, int, string, bool
                    arr.insert(index, v);

                case "e": //Enum
                    //TO DO !
                    trace("Deserialization for enum array is not supported");

                case "g" : //GameObject
                    var instAndData : InstAndData = cast map.get(v);
                    arr.insert(index, instAndData.inst);

                case "c" : //Component
                    var instAndData : InstAndData = cast map.get(v);
                    arr.insert(index, instAndData.inst);
                
                case "u" : //UID
                    arr.insert(index, Int64.parseString(v));

                case "a" : //Array
                    arr.insert(index, getArray(k, v));

                case _ :
                    trace('Deserialization not supported for array of ${fieldName}');
            }
        }

        return arr;
    }

    static function getClassPath(c : Dynamic) : String
    {
        var path : String = "";
        var s : String = Std.string(Type.getClass(c));

        var len : Int = s.length;
        var i : Int = 0;
        var ichar : String = "";

        while (true)
        {
            if(i >= len)
                break;

            ichar = s.charAt(i);

            if (ichar == "$")
                ichar = "";

            path += ichar;
            i++;
        }
        return path;
    }
    //#endregion
}

typedef InstAndData =
{
    var inst : Dynamic;
    var data : StringMap<Dynamic>;
}