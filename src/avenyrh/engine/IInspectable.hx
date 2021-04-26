package avenyrh.engine;

interface IInspectable 
{
    /**
     * Unique identifier
     */
    var uID (default, null) : Int;

    /**
     * Name that will appear in the header
     */
    var name (default, null) : String;

    /**
     * Draws the Inspector windows
     */
    function drawInspector() : Void;
}