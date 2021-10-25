package avenyrh.engine;

import haxe.Int64;

@:rtti
class Uniq extends hl.BaseType.Class
{
    public var uID (default, null) : Int64;

    public function new(?id : Null<Int64>)
    {
        if(id == null)
        {
            var mn : Float = 0 - .4999;
            var mx : Float = 999999999999 + .4999;
            var v = mn + (mx - mn) * Math.random();
            uID = Int64.fromFloat(v > 0 ? v + .5 : v < 0 ? v - .5 : 0);
        }
        else 
            uID = id;
    }
}