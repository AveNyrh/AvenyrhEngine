package avenyrh.pathfinding;

class Cell implements ICell
{
    /**
     * X position on the grid
     */
    public var x : Int;
    /**
     * Y position on the grid
     */
    public var y : Int;
    /**
     * Parent cell, used by the pathfinding
     */
    public var parent : ICell;
    /**
     * Index in the Heap
     */
    public var heapIndex : Int;
    /**
     * Total cost
     */
    public var fCost (get, null) : Int;
    /**
     * Cost to start position
     */
    public var gCost : Int;
    /**
     * Cost to end position
     */
    public var hCost : Int;
    /**
     * Is this cell walkable, if not, the pathfinding will avoid it
     */
    public var isWalkable : Bool = true; 

    public function new(x : Int, y : Int)
    {
        this.x = x;
        this.y = y;
    }

    public function compareTo(other : IHeapItem) : Int
    {
        var cell : ICell = cast other;
        var c : Int = compare(fCost, cell.fCost);

        if(c == 0)
            c = compare(hCost, cell.hCost);

        return -c;
    }

    /**
     * Same as int.CompareTo in C#
     */
    inline function compare(a : Int, b : Int) : Int
    {
        return a > b ? 1 : a == b ? 0 : -1;
    }

    function get_fCost() 
    {
        return gCost + hCost;    
    }
}