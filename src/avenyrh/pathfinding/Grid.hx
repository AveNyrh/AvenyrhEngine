package avenyrh.pathfinding;

class Grid
{
    /**
     * Width of the grid
     */
    public var width (default, null) : Int;
    /**
     * Height of the grid
     */
    public var height (default, null) : Int;
    /**
     * Number of cells in the grid
     */
    public var maxSize (get, null) : Int;
    /**
     * Cell grid
     */
    public var cells : Array<Array<ICell>>;

    public function new(width : Int, height : Int)
    {
        this.width = width;
        this.height = height;

        cells = [];
    }

    //--------------------
    //Public API
    //--------------------
    /**
     * Returns the cell in the grid at the coordinate [x, y]
     */
    public inline function getCell(x : Int, y : Int) : Null<ICell>
    {
        if(x >= 0 && x < width && y >= 0 && y < height)
            return cells[x][y];

        return null;
    }

    /**
     * Sets the cell in the grid at the cell position
     */
    public inline function setCell(cell : ICell) 
    {
        var x : Int = cell.x;
        var y : Int = cell.y;

        if(cells[x] == null)
            cells[x] = [];

        if(x >= 0 && x < width && y >= 0 && y < height)
            cells[x][y] = cell;
    }

    /**
     * Returns the 4 neighbours plus the diagonal ones 
     */
    public function get8Neighbours(cell : ICell) : Array<ICell>
    {
        var neighbours : Array<ICell> = [];

        for(x in -1 ... 2)
        {
            for(y in -1 ... 2)
            {
                if(x != 0 || y != 0)
                {
                    var checkX : Int = cell.x + x;
                    var checkY : Int = cell.y + y;
                    var n : Null<ICell> = getCell(checkX, checkY);

                    if(n != null)
                        neighbours.push(n);
                }                    
            }
        }

        return neighbours;
    }

    /**
     * Returns the top, right, bottom and left neighbours
     */
    public function get4Neighbours(cell : ICell) : Array<ICell>
    {
        var neighbours : Array<ICell> = [];

        for(x in -1 ... 2)
        {
            for(y in -1 ... 2)
            {
                if((x != 0|| y != 0) && x != y && x != -y)
                {
                    var checkX : Int = cell.x + x;
                    var checkY : Int = cell.y + y;
                    var n : Null<ICell> = getCell(checkX, checkY);

                    if(n != null)
                        neighbours.push(n);
                }                    
            }
        }

        return neighbours;
    }

    //--------------------
    //Getters & Setters
    //--------------------
    inline function get_maxSize() : Int
    {
        return width * height;    
    }
}