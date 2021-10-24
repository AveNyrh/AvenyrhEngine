package avenyrh.engine;

using Lambda;
import avenyrh.utils.JsonUtils;
import sys.io.FileInput;
import haxe.ds.StringMap;
import sys.io.FileOutput;
import sys.io.File;

class SceneSerializer 
{
    static inline var space : String = " ";
    
    static inline var tab : String = "\t";

    static inline var lineBreak : String = "\n";

    public static var path : String = "examples/res/scenes/";

    static var fi : FileInput;
    
    //-------------------------------
    //#region Public static API
    //-------------------------------
    public static function serialize(scene : Scene) @:privateAccess
    {
        
        var data : StringMap<Dynamic> = new StringMap();
        var rtti : haxe.rtti.CType.Classdef = haxe.rtti.Rtti.getRtti(Type.getClass(scene));

        var currentObject : StringMap<Dynamic> = new StringMap();

        //Scene
        currentObject.set("Name", scene.name);
        currentObject.set("Class path", getClassPath(scene));
        currentObject.set("uID", scene.uID.toString());

        for(f in rtti.fields)
        {
            if((f.isPublic || f.meta.exists(m -> m.name == "serializable")) && f.type.getName() != "CFunction")
            {
                currentObject.set(f.name, Reflect.getProperty(scene, f.name));
            }
        }

        data.set("Scene", currentObject);

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

        var sceneData : StringMap<Dynamic> = JsonUtils.parseToStringMap(data.get("Scene"));

        var c = Type.resolveClass(sceneData.get("Class path"));

        //To build a class from string
        var instance : Class<Dynamic> = Type.createInstance(c, [sceneData.get("Name")]);
        var rtti : haxe.rtti.CType.Classdef = haxe.rtti.Rtti.getRtti(Type.getClass(instance));
        var fields : Array<String> = Type.getClassFields(instance);

        for(f in rtti.fields)
        {
            if((f.isPublic || f.meta.exists(m -> m.name == "serializable")) && f.type.getName() != "CFunction" && sceneData.exists(f.name))
            {
                var n : String = f.name;
                switch (f.type)
                {
                    case CAbstract("Float", []) : //Float
                        Reflect.setField(instance, f.name, sceneData.get(f.name));

                    case CAbstract("Int", []) : //Int
                        var sd = sceneData.get(f.name);
                        Reflect.setField(instance, f.name, sceneData.get(f.name));

                    case CAbstract("Bool", []) : //Bool
                        Reflect.setField(instance, f.name, sceneData.get(f.name) == "true");

                    case CClass("String", []) : //String
                        Reflect.setField(instance, f.name, sceneData.get(f.name));

                    case CEnum(_, []) : //Enum
                        var ev : EnumValue = cast Reflect.getProperty(instance, f.name);
                        var e : Enum<Dynamic> = Type.getEnum(ev);
                        Reflect.setField(instance, f.name, Type.createEnumIndex(e, ev.getIndex()));

                    case CClass("GameObject", []) : //GameObject
                        trace('GameObject ${f.name}');
    
                    case _:
                        trace('Not supported deserialization for ${f.name}');
                }
            }
        }

        SceneManager.addScene(cast instance);

        trace('${sceneData.get("Name")} deserialized');

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

    static function getNameAndData(str : String) : NameAndData
    {
        var len : Int = str.length;
        var s : String = "";
        var i : Int = 0;
        var ichar : String = "";

        while (true)
        {
            if(i >= len)
                break;

            ichar = str.charAt(i);

            if(ichar == ".")
                ichar = "/";
            else if (ichar == "$")
                ichar = "";

            s += ichar;
            i++;
        }

        return {name : "", data : ""};
    }
    //#endregion
}

typedef NameAndData =
{
    var name : String;
    var data : Dynamic;
}