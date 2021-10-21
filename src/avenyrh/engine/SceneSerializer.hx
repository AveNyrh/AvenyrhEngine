package avenyrh.engine;

import haxe.Int64;
import avenyrh.gameObject.Component;
import avenyrh.gameObject.GameObject;
using Lambda;
import avenyrh.utils.JsonUtils;
import haxe.Unserializer;
import sys.io.File;

class SceneSerializer 
{
    static inline var space : String = " ";
    
    static inline var tab : String = "\t";

    static inline var lineBreak : String = "\n";

    public static var path : String = "examples/res/scenes/";

    static var buf : StringBuf;

    static var indent : Int;
    
    //-------------------------------
    //#region Public static API
    //-------------------------------
    public static function serialize(scene : Scene) @:privateAccess
    {
        buf = new StringBuf();
        indent = 0;
        
        //var data : StringMap<Dynamic> = new StringMap();
        var rtti : haxe.rtti.CType.Classdef = haxe.rtti.Rtti.getRtti(Type.getClass(scene));

        //Scene header
        //To add manualy
        //- camera
        //- process children

        addValue("Name", scene.name);
        addValue("uID", scene.uID.toString());
        //addObject("Camera", scene.camera);

        for(f in rtti.fields)
        {
            if((f.isPublic || f.meta.exists(m -> m.name == "serializable")) && f.type.getName() != "CFunction")
            {
                addValue(f.name, Reflect.getProperty(scene, f.name));
            }
        }

        // for(go in @:privateAccess scene.allGO)
        // {
        //     rtti = haxe.rtti.Rtti.getRtti(Type.getClass(go));
        //     trace(rtti);

        //     for(f in rtti.fields)
        //     {
        //         if(f.isPublic || f.meta.exists(m -> m.name == "serializable"))
        //         {
        //             data.set(f.name, Reflect.getProperty(go, f.name));
        //         }
        //     }
        // }

        var p : String = path + scene.name + ".scene";

        var fo = File.write(p, false);
        fo.writeString(buf.toString());
        fo.close();
		
		trace("Saved scene");
		trace("Path : " + p);
		trace("Data : \n" + buf.toString());
    }

    public static function deserialize(name : String) : Bool
    {
        var obj : Dynamic = Unserializer.run(hxd.Res.sav.particles.entry.getBytes().toString());
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

    static function addValue(name : Null<String>, value : Dynamic, autoLineBreak : Bool = true) @:privateAccess
    {
        var lb : String = autoLineBreak ? lineBreak : "";

        switch Type.typeof(value) 
        {
            case TNull, TInt, TBool :
				name == null ? buf.add('$value$lb') : buf.add('"$name" : $value$lb');

			case TFloat :
				var strFloat = value == Std.int(value) ? value + ".0" : Std.string(value);
				name == null ? buf.add('$strFloat$lb') : buf.add('"$name" : $strFloat$lb');
            
            case TClass(String) :
                name == null ? buf.add('$value$lb') : buf.add('"$name" : $value$lb');

            case TClass(GameObject) :
                var go : GameObject = cast value;
                name == null ? buf.add('${go.uID.toString()}$lb') : buf.add('"$name" : ${go.uID.toString()}$lb');

            case TClass(Component) :
                var comp : Component = cast value;
                name == null ? buf.add('${comp.uID.toString()}$lb') : buf.add('"$name" : ${comp.uID.toString()}$lb');

            case TClass(Array) :
                addArray(name, value);

            case TEnum(e) :
                var ev : EnumValue = cast value;
                if(ev.getParameters().length > 0)
                    throw 'Unsupported parametered enum $name : ${e.getName()}';
                name == null ? buf.add('${ev.getName()}$lb') : buf.add('"$name" : ${ev.getName()}$lb');

            //TO DO : Maps

			case _:
				throw 'Unknown value type $name = $value (' + Type.typeof(value) + ')';
        }
    }

    static function addArray(name : Null<String>, arr : Array<Dynamic>)
    {
        if(arr.length == 0)
        {
            name == null ? buf.add('[]$lineBreak') : buf.add('"$name" : []$lineBreak');
        }

        if(name!=null)
            buf.add('"$name" :$lineBreak');
        buf.add('[$lineBreak');

        indent++;
        for(i in 0 ... arr.length) 
        {
            addIndent();
            addValue(null, arr[i], false);
            if(i < arr.length - 1)
                buf.add(',$lineBreak');
        }
        indent--;

        buf.add(lineBreak);
        addIndent();
        buf.add(']$lineBreak');
    }

    /**
     * Adds the indentation to the StrinBuf : indent * tab
     */
    static function addIndent()
    {
		for(i in 0 ... indent)
			buf.add(tab);
    }
    //#endregion
}