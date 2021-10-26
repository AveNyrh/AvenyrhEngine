package avenyrh.engine;

using Lambda;
import haxe.Int64;
import avenyrh.engine.Uniq;
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

    public static var path : String = "examples/res/scenes/";

    static var map : StringMap<Dynamic>;

    static var rtti : haxe.rtti.CType.Classdef;

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

        //Add gameobjects, components ...
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

    public static function deserialize(name : String) : Bool
    {
        map = new StringMap<Dynamic>();
        var uniqMap : StringMap<Uniq> = new StringMap<Uniq>();

        //Retrieve content
        var p : String = path + name + ".scene";
        var s : String = File.getContent(p);
        var dyn : haxe.DynamicAccess<Dynamic> = haxe.Json.parse(s);
        var data : StringMap<haxe.DynamicAccess<Dynamic>> = JsonUtils.parseToStringMap(dyn);

        //------ Scene ------
        //Retrieve scene specific data
        var sceneData : StringMap<Dynamic> = JsonUtils.parseToStringMap(data.get("Scene"));

        //Build a scene class from string
        var c = Type.resolveClass(sceneData.get("s_classPath"));
        var instance : Class<Dynamic> = Type.createInstance(c, [sceneData.get("s_name")]);

        //Set scene data
        setInstanceFields(instance, sceneData);
        uniqMap.set(sceneData.get("u_uID"), cast instance);

        //Cast instance to Scene to instantiate gameObject
        var scene : Scene = cast instance;

        //------ RootGo ------
        var rootGo : GameObject = new GameObject("Root", null, Int64.parseString(sceneData.get("g_rootGo")));
        uniqMap.set(sceneData.get("g_rootGo"), cast rootGo);
        @:privateAccess scene.rootGo = rootGo;

        //------ Camera ------
        //Retrieve camera specific data
        var cameraData : StringMap<Dynamic> = JsonUtils.parseToStringMap(data.get("Camera"));

        //Build a camera class from string
        var c = Type.resolveClass(cameraData.get("s_classPath"));
        var instance : Class<Dynamic> = Type.createInstance(c, [cameraData.get("s_name")]);

        //Set camera data
        setInstanceFields(instance, cameraData);
        scene.camera = cast instance;
        @:privateAccess scene.camera.scene = scene;

        //------ Game Objects ------
        var goData : Array<Dynamic> = cast data.get("GameObjects");

        if(goData != null && goData.length > 0)
        {
            for(go in goData)
            {
                //Create instance
                var d : StringMap<Dynamic> = JsonUtils.parseToStringMap(go);
                var c = Type.resolveClass(d.get("s_classPath"));
                var inst : Class<Dynamic> = Type.createInstance(c, [d.get("s_name")]);

                //Set gameObject data
                setInstanceFields(inst, d);

                //Store gameObject for later
                uniqMap.set(d.get("u_uID"), cast inst);
            }
        }

        //------ Components ------
        var compData : Array<Dynamic> = cast data.get("Components");

        if(compData != null && compData.length > 0)
        {
            for(comp in compData)
            {
                //Create instance
                var d : StringMap<Dynamic> = JsonUtils.parseToStringMap(comp);
                var c = Type.resolveClass(d.get("s_classPath"));
                var inst : Class<Dynamic> = Type.createInstance(c, [d.get("s_name")]);

                //Set gameObject data
                setInstanceFields(inst, d);

                //Store gameObject for later
                uniqMap.set(d.get("u_uID"), cast inst);
            }
        }

        //Restore gameObject and component fields refs
        for(uid => inst in uniqMap)
        {
            //For each uniq that has been referenced somewhere
            var arr : Array<String> = map.get(uid);

            //Null check just in case, should never happen
            if(arr == null)
                continue;

            for(a in arr)
            {
                //Get reference infos
                var value : Array<String> = a.split(underscore);
                var fieldName : String = value[0];
                var objUID : String = value[1];

                Reflect.setField(inst, fieldName, cast uniqMap.get(objUID));
            }
        }

        SceneManager.addScene(scene);

        trace('${sceneData.get("s_Name")} deserialized');

        return false;
    }
    //#endregion

    //-------------------------------
    //#region Private static API
    //-------------------------------
    static function addObject(object : Dynamic, ?newObject : Bool = true, ?currentClass : Null<Class<Dynamic>> = null) : StringMap<Dynamic>
    {
        if(newObject)
        {
            map = new StringMap<Dynamic>();
            addValue("classPath", getClassPath(object));
        }

        if(currentClass != null)
            rtti = haxe.rtti.Rtti.getRtti(currentClass);
        else
            rtti = haxe.rtti.Rtti.getRtti(Type.getClass(object));

        //Add additional fields
        for(f in rtti.fields)
        {
            if((f.isPublic || f.meta.exists(m -> m.name == "serializable")) && !f.meta.exists(m -> m.name == "noSerial") && f.type.getName() != "CFunction")
            {
                addValue(f.name, Reflect.getProperty(object, f.name));
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
     * s : string
     * u : uID
     */
    static function addValue(name : String, value : Dynamic)
    {
        //Handle uID here, problem with Int64 class type in the switch
        if(name == "uID")
        {
            map.set('u_$name', Int64.toStr(value));
            return;
        }

        switch Type.typeof(value) 
        {
            case TInt :
                map.set('i_$name', value);

            case TBool :
                map.set('b_$name', value);

            case TFloat :
                map.set('f_$name', value);

            case TClass(String) :
                map.set('s_$name', value);

            case TClass(GameObject) :
                var go : GameObject = cast value;
                map.set('g_$name', Int64.toStr(go.uID));

            case TClass(Component) :
                var comp : Component = cast value;
                map.set('c_$name', Int64.toStr(comp.uID));

            case TClass(Array) :
                map.set('a_$name', value);

            case TEnum(e) :
                map.set('e_$name', value);

            //TO DO : Maps

            case _:
                trace('Unknown value type $name = $value (' + Type.typeof(value) + ')');
        }
    }

    static function setInstanceFields(inst : Dynamic, dataMap : StringMap<Dynamic>)
    {
        var uID : String = dataMap.get("u_uID");
        var fields : Array<String> = Type.getClassFields(inst);

        for(key => value in dataMap)
        {
            var arr : Array<String> = key.split(underscore);
            var type : String = arr[0];
            var fieldName : String = arr[1];

            if(!fields.contains(fieldName))
                continue;

            switch (type)
            {
                case "f", "i", "s" : //float, int, string
                    Reflect.setField(inst, fieldName, dataMap.get(key));

                case "b" : //Bool
                    Reflect.setField(inst, fieldName, dataMap.get(key) == "true");

                case "e": //Enum
                    var ev : EnumValue = cast Reflect.getProperty(inst, fieldName);
                    var e : Enum<Dynamic> = Type.getEnum(ev);
                    Reflect.setField(inst, fieldName, Type.createEnumIndex(e, ev.getIndex()));

                case "g" : //GameObject
                    var arr : Array<String> = map.get(uID);

                    //Create array if first time
                    if(arr == null)
                        arr = [];

                    //Push data to this format : myGameObjectField_uID
                    arr.push('${fieldName}_${value}');
                    map.set(uID, arr);

                case "c" : //Component
                    var arr : Array<String> = map.get(uID);

                    //Create array if first time
                    if(arr == null)
                        arr = [];

                    //Push data to this format : myComponentField_uID
                    arr.push('${fieldName}_${value}');
                    map.set(uID, arr);
                
                case "u" : //UID
                    Reflect.setField(inst, fieldName, Int64.parseString(dataMap.get(key)));

                case _:
                    trace('Deserialization not supported for ${fieldName}');
            }
        }
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