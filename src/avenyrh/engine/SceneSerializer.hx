package avenyrh.engine;

using Lambda;
import avenyrh.gameObject.Component;
import avenyrh.gameObject.GameObject;
import avenyrh.utils.JsonUtils;
import haxe.ds.StringMap;
import sys.io.FileOutput;
import sys.io.File;

class SceneSerializer 
{
    static inline var space : String = " ";
    
    static inline var tab : String = "\t";

    static inline var lineBreak : String = "\n";

    static inline var underscore : String = "_";

    public static var path : String = "examples/res/scenes/";

    static var map : StringMap<Dynamic>;

    //-------------------------------
    //#region Public static API
    //-------------------------------
    public static function serialize(scene : Scene) @:privateAccess
    {
        var data : StringMap<Dynamic> = new StringMap();
        var rtti : haxe.rtti.CType.Classdef = haxe.rtti.Rtti.getRtti(Type.getClass(scene));

        map = new StringMap();

        //Scene
        addValue("Name", scene.name);
        addValue("Class path", getClassPath(scene));
        addValue("uID", scene.uID.toString());

        for(f in rtti.fields)
        {
            if((f.isPublic || f.meta.exists(m -> m.name == "serializable")) && f.type.getName() != "CFunction")
            {
                addValue(f.name, Reflect.getProperty(scene, f.name));
            }
        }

        data.set("Scene", map);

        //Add gameobjects, components ...

        //Write data
        var p : String = path + scene.name + ".scene";
        var fo : FileOutput = File.write(p, false);
        fo.writeString(JsonUtils.stringify(data, Full));
        fo.close();

        trace('${scene.name} serialized');
    }

    public static function deserialize(name : String) : Bool
    {
        //Retrieve content
        var p : String = path + name + ".scene";
        var s : String = File.getContent(p);
        var dyn : haxe.DynamicAccess<Dynamic> = haxe.Json.parse(s);
        var data : StringMap<haxe.DynamicAccess<Dynamic>> = JsonUtils.parseToStringMap(dyn);

        //Retrieve scene specific data
        var sceneData : StringMap<Dynamic> = JsonUtils.parseToStringMap(data.get("Scene"));

        //Build a class from string
        var c = Type.resolveClass(sceneData.get("s_Class path"));
        var instance : Class<Dynamic> = Type.createInstance(c, [sceneData.get("s_Name")]);

        //Set scene data
        setInstanceFields(instance, sceneData);

        //Add GameObject, Components ...

        SceneManager.addScene(cast instance);

        trace('${sceneData.get("s_Name")} deserialized');

        return false;
    }
    //#endregion

    //-------------------------------
    //#region Private static API
    //-------------------------------
    static function addObject(name : String, object : Dynamic)
    {
        switch Type.typeof(object)
        {
			case _:
				throw 'Unknown object type $name = $object (' + Type.typeof(object) + ')';
        }
    }

    /**
     * Prefixes :
     * a : array
     * b : bool
     * c : component
     * e : enum
     * f : float
     * g : gameObject
     * i : int
     * s : string
     */
    static function addValue(name : String, value : Dynamic) @:privateAccess
    {
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
                map.set('g_$name', go.uID.toString());

            case TClass(Component) :
                var comp : Component = cast value;
                map.set('c_$name', comp.uID.toString());

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
        var fields : Array<String> = Type.getClassFields(inst);

        for(key => value in dataMap)
        {
            if(!fields.contains(key))
                continue;

            var arr : Array<String> = key.split(underscore);
            var type : String = arr[0];
            var fieldName : String = arr[1];

            trace ('$type - $fieldName = $value');

            switch (type)
            {
                case "f", "i", "s" : //float, int, string
                    Reflect.setField(inst, fieldName, dataMap.get(fieldName));

                case "b" : //Bool
                    Reflect.setField(inst, fieldName, dataMap.get(fieldName) == "true");

                case "e": //Enum
                    var ev : EnumValue = cast Reflect.getProperty(inst, fieldName);
                    var e : Enum<Dynamic> = Type.getEnum(ev);
                    Reflect.setField(inst, fieldName, Type.createEnumIndex(e, ev.getIndex()));

                case "g" : //GameObject
                    trace('GameObject ${fieldName}');

                case "c" : //Component
                    trace('GameObject ${fieldName}');

                case _:
                    trace('Not supported deserialization for ${fieldName}');
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