package avenyrh.pathfinding;

interface ICell extends IHeapItem
{
    /**
     * X position on the grid
     */
    var x : Int;
    /**
     * Y position on the grid
     */
    var y : Int;
    /**
     * Parent cell, used by the pathfinding
     */
    var parent : ICell;
    /**
     * Total cost
     */
    var fCost (get, null) : Int;
    /**
     * Cost to start position
     */
    var gCost : Int;
    /**
     * Cost to end position
     */
    var hCost : Int;
    /**
     * Is this cell walkable, if not, the pathfinding will avoid it
     */
    var isWalkable : Bool; 
}