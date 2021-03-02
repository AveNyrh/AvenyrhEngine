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
     * Draws the Inspector windows
     */
    function drawInspector(inspector : Inspector) : Void;

    /**
     * Are the x and y inside the bounds of the object ?
     */
    function isInBounds(x : Float, y : Float) : Bool;
}