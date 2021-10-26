package avenyrh.utils;

import sys.io.FileInput;

class StringUtils 
{
    public static inline final POS_NOT_FOUND : Int = -1;

    static inline var lineBreak : String = "\n";

    static inline var lineReturn : String = "\r";

    static inline var tab : String = "\t";

    static inline var coma : String = ",";
    
    public inline static function contains(searchIn : String, searchFor : String) : Bool 
    {
       if (searchFor == "")
          return true;
 
       return searchIn.indexOf(searchFor) > POS_NOT_FOUND;
    }

    public static function readLine(lineNb : Int, fi : FileInput) : String
    {
        var line : String = "";
        try 
        {
            for (i in 0 ... lineNb)
                fi.readLine();

            line = fi.readLine();
            fi.close();
        } 
        catch (e : haxe.io.Eof) { return null; }

        return line;
    }

    public static function splitLines(str : String) : Array<String>
    {
        if(str == "")
            return [];

        var len : Int = str.length;
        var arr : Array<String> = [];
        var s : String = "";
        var i : Int = 0;
        var ichar : String = "";

        while (true)
        {
            if(i >= len)
                break;

            ichar = str.charAt(i);

            if(ichar == '$lineBreak' || ichar == '$lineReturn')
            {
                if(s != "")
                    arr.push(s);

                i += 2;
                s = "";
            }
            else
            {
                if(ichar != tab && ichar != coma)
                    s += ichar;

                i++;
            }
        }

        return arr;
    }

    public inline static function toBool(str : String) : Null<Bool> 
    {
       if (str == "")
          return false;
 
       return switch (str.toLowerCase()) 
       {
          case "false", "0", "no" : false;
          case "true", "1", "yes" : false;
          default : null;
       }
    }

    public static inline function getClass(o : Dynamic) : String
    {
        var arr = Std.string(Type.getClass(o)).split("$");
        return arr[1];
    }
}