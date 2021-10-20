package avenyrh.engine;

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
    public static function serialize(scene : Scene)
    {
        buf = new StringBuf();
        indent = 0;
        
        //var data : StringMap<Dynamic> = new StringMap();
        var rtti : haxe.rtti.CType.Classdef = haxe.rtti.Rtti.getRtti(Type.getClass(scene));

        //Scene header
        //To add manualy
        //- name
        //- ui Flow options
        //- camera
        //- process children

        for(f in rtti.fields)
        {
            if((f.isPublic || f.meta.exists(m -> m.name == "serializable")) && f.type.getName() != "CFunction")
            {
                //data.set(f.name, Reflect.getProperty(scene, f.name));
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
        //JsonUtils.saveJson(p, buf.toString());

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

    }

    static function addValue(name : String, value : Dynamic)
    {
        switch Type.typeof(value) 
        {
            case TNull, TInt, TBool :
				buf.add('"$name" : $value$lineBreak');

			case TFloat :
				var strFloat = value == Std.int(value) ? value + ".0" : Std.string(value);
				buf.add('"$name" : $strFloat$lineBreak');
            
            case TClass(String) :
                buf.add('"$name" : $value$lineBreak');

            //TO DO : Array, Maps, GO, Components, Enums

			case _:
				throw 'Unknown value type $name = $value (' + Type.typeof(value) + ')';
        }
    }
    //#endregion
}