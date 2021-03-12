package avenyrh.pathfinding;

//Haxe version of Sebastian Lague pathfinding
//https://www.youtube.com/playlist?list=PLFt_AvWsXl0cq5Umv3pMC9SPnKjfp9eGW
class AStarPathfinding extends Pathfinding
{
    /**
     * Grid on which the pathfinding happens
     */
    public var grid : Grid;
    /**
     * Simplify the path or not \
     * When true, it will return only waypoints when the path changes direction
     */
    public var simplify : Bool = true;

    public function new(grid : Grid)
    {
        this.grid = grid;
    }

    //-------------------------------
    //#region Public API
    //-------------------------------
    public override function findPath(startPos : Vector2, targetPos : Vector2)
    {
        //Sets the starting and the target cell
        var startCell : ICell = grid.getCell(Std.int(startPos.x), Std.int(startPos.y));
        var targetCell : ICell = grid.getCell(Std.int(targetPos.x), Std.int(targetPos.y));

        var waypoints : Array<Vector2> = [];
        var pathSucces : Bool = false;

        //Creates the open and close sets
        var openSet : Heap = new Heap();
        var closeSet : Heap = new Heap();
        openSet.add(startCell);

        while (openSet.count > 0)
        {
            //Assigns the cell with the lowest fCost as the current cell
            var currentCell : ICell = cast openSet.removeFirst();
            closeSet.add(currentCell);

            //Exits when we have found the target and retrace the path
            if(currentCell == targetCell)
            {
                pathSucces = true;
                break;
            }

            //Get all adjacent cells
            var adjacentCells : Array<ICell> = grid.get8Neighbours(currentCell);

            //Adds all neighbours to the open set
            for(neighbour in adjacentCells)
            {
                if(!closeSet.contains(neighbour) && neighbour.isWalkable)
                {
                    //Calculate new movement cost
                    var newMouvementCostToNeighbour = currentCell.gCost + getDistance(currentCell, neighbour);

                    if(newMouvementCostToNeighbour < neighbour.gCost || !openSet.contains(neighbour))
                    {
                        //Update costs
                        neighbour.gCost = newMouvementCostToNeighbour;
                        neighbour.hCost = getDistance(neighbour, targetCell);

                        neighbour.parent = currentCell;

                        if(!openSet.contains(neighbour))
                            openSet.add(neighbour);
                        else
                            openSet.updateItem(neighbour);
                    }
                }
            }
        }

        if(pathSucces)
            waypoints = retracePath(startCell, targetCell);

        @:privateAccess pathRequestHandler.finishedProcessingPath(waypoints, pathSucces);
    }
    //#endregion

    //-------------------------------
    //#region Private API
    //-------------------------------
    /**
     * Retrace the path from one Cell to another
     */
    function retracePath(startCell : ICell, endCell : ICell) : Array<Vector2>
    {
        var path : Array<ICell> = [];
        var currentCell : ICell = endCell;

        while(currentCell != startCell)
        {
            path.push(currentCell);
            currentCell = currentCell.parent;
        }

        var waypoints = simplifyPath(path, startCell);
        waypoints.reverse();
        
        return waypoints;
    }

    /**
     * Puts waypoints on the path when it changes direction
     */
    function simplifyPath(path : Array<ICell>, startCell : ICell) : Array<Vector2>
    {
        var waypoints : Array<Vector2> = [];

        //If no need to simplify
        if(path.length <= 2)
        {
            for(c in path)
                waypoints.push(new Vector2(c.x, c.y));

            return waypoints;
        }

        if(!simplify)
        {
            for(c in path)
                waypoints.push(new Vector2(c.x, c.y));
        }
        else
        {
            var oldDir : Vector2 = new Vector2(path[0].x - startCell.x, path[0].y - startCell.y);

            for(i in 0 ... path.length - 1)
            {
                var newDir : Vector2 = new Vector2(path[i].x - path[i + 1].x, path[i].y - path[i + 1].y);

                if(newDir != oldDir)
                    waypoints.push(new Vector2(path[i].x, path[i].y));

                oldDir = newDir;
            }
        }

        return waypoints;
    }

    /**
     * Return the distance cost between two cells\
     * This allows diagonals
     */
    function getDistance(cellA : ICell, cellB : ICell) : Int
    {
        var distX : Int = AMath.iabs(cellA.x - cellB.x);
        var distY : Int = AMath.iabs(cellA.y - cellB.y);

        if(distX > distY)
            return 14 * distY + 10 * (distX - distY);

        return 14 * distX + 10 * (distY - distX);
    }
    //#endregion
}