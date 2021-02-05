package avenyrh.engine;

interface IInspectable 
{
    /**
     * See debug lines
     */
    var debug (default, set) : Bool;
    /**
     * Color of the debug lines
     */
    var debugColor : Int;

    /**
     * Returns all info that should appear on the Inspector window
     */
    function getInspectorInfo() : String;

    /**
     * Are the x and y inside the bounds of the object ?
     */
    function isInBounds(x : Float, y : Float) : Bool;
}