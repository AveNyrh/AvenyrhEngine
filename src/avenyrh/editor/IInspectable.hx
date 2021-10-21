package avenyrh.editor;

import haxe.Int64;

interface IInspectable 
{
    /**
     * Unique identifier
     */
    var uID (default, null) : Int64;

    /**
     * Name that will appear in the header
     */
    var name (default, null) : String;

    /**
     * Draws the Inspector windows
     */
    function drawInspector() : Void;

    /**
     * Draw all children in the hierarchy
     */
    function drawHierarchy() : Null<IInspectable>;
}