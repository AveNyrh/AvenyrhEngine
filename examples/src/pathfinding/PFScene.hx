package examples.src.pathfinding;

import h2d.Text;
import avenyrh.Vector2;
import h2d.Object;
import avenyrh.pathfinding.*;
import avenyrh.engine.Scene;
import avenyrh.engine.SceneManager;

/**
 * Example scene to try out the AStarPathfinding \
 * Controls : \
 *      - Press "A" to set a cell as the starting cell \
 *      - Press "Mouse Left" to set a cell to unwalkable \
 *      - Press "Mouse Right" to set a cell back from unwalkable to idle \
 *      - Press "Space" to enable or disable the simplify path
 *      - Press "R" to reset the grid
 */
class PFScene extends Scene
{
    /**
     * Grid
     */
    var grid : Grid;
    /**
     * Object that contains the grid bitmaps
     */
    var gridHolder : Object;
    /**
     * Pathfinding used
     */
    var pf : AStarPathfinding;
    /**
     * Request handler
     */
    var pfRequest : PathRequestHandler;
    /**
     * Size of a cell
     */
    var size : Int = 20;
    /**
     * Text for "simflify"
     */
    var text : Text;
    /**
     * Starting cell of the pathfinding
     */
    public var startCell : Null<ExampleCell>;
    /**
     * Ending cell of the pathfinding
     */
    public var endCell (default, set) : ExampleCell;
    /**
     * Path
     */
    var p : Array<ExampleCell>;

    override public function new() 
    {
        super("Pathfinding example scene");    
    }

    override function added() 
    {
        super.added();

        var w : Int = 100;
        var h : Int = 100;

        grid = new Grid(w, h);
        pf = new AStarPathfinding(grid);
        pf.simplify = false;
        pfRequest = new PathRequestHandler("Path request handler", this, pf);
        p = [];

        text = new Text(hxd.res.DefaultFont.get(), ui);
        text.scale(2);
        text.text = 'simplify = ${pf.simplify}';

        gridHolder = new Object(scroller);
        gridHolder.setPosition(-1000, -600);

        var cell : ExampleCell;

        for(x in 0 ... w)
        {
            for(y in 0 ... h)
            {
                cell = new ExampleCell(x, y, size, gridHolder, this);
                grid.setCell(cell);
            }
        }
    }

    override function update(dt:Float) 
    {
        super.update(dt);

        if(hxd.Key.isPressed(hxd.Key.RIGHT))
        {
            SceneManager.addScene(new GameObjectScene());
            return;
        }
        else if(hxd.Key.isPressed(hxd.Key.LEFT))
        {
            SceneManager.addScene(new UIScene());
            return;
        }

        if(hxd.Key.isPressed(hxd.Key.R))
        {
            for(x in 0 ... grid.width)
            {
                for(y in 0 ... grid.height)
                {
                    var ec : ExampleCell = cast grid.getCell(x, y);
                    ec.resetCell(true);
                    startCell = null;
                }
            }
        }
        
        if(hxd.Key.isPressed(hxd.Key.A))
        {
            var x : Int = ExampleCell.currentHoverCell.x;
            var y : Int = ExampleCell.currentHoverCell.y;

            var ec : ExampleCell = cast grid.getCell(x, y);

            if(ec == startCell)
            {
                startCell.resetCell(true);
                startCell = null;

                for(c in p)
                    c.resetCell(false);

                return;
            }

            ec.state = Locked;
            ec.bitmap.tile = ec.start;

            if(startCell != null)
            {
                startCell.resetCell(true);

                for(c in p)
                    c.resetCell(false);
            }

            startCell = ec;
        }

        if(hxd.Key.isPressed(hxd.Key.SPACE))
        {
            pf.simplify = !pf.simplify;
            text.text = 'simplify = ${pf.simplify}';
        }

        if(hxd.Key.isDown(hxd.Key.MOUSE_LEFT))
        {
            var x : Int = ExampleCell.currentHoverCell.x;
            var y : Int = ExampleCell.currentHoverCell.y;

            var ec : ExampleCell = cast grid.getCell(x, y);

            if(ec.state != Unwalkable && ec.state != Locked)
            {
                ec.state = Unwalkable;
                ec.bitmap.tile = ec.unwalkable;
                ec.isWalkable = false;
            }                 
        }

        if(hxd.Key.isDown(hxd.Key.MOUSE_RIGHT))
        {
            var x : Int = ExampleCell.currentHoverCell.x;
            var y : Int = ExampleCell.currentHoverCell.y;

            var ec : ExampleCell = cast grid.getCell(x, y);

            if(ec.state == Unwalkable)
            {
                ec.state = Idle;
                ec.bitmap.tile = ec.idle;
                ec.isWalkable = true;
            }                 
        }
    }

    function callback(path : Array<Vector2>, succes : Bool)
    {
        if(!succes)
            return;

        p = [];

        for(v in path)
        {
            var ec : ExampleCell = cast grid.getCell(Std.int(v.x), Std.int(v.y));
            ec.bitmap.tile = ec.occupied;
            ec.state = Occupied;
            p.push(ec);
        }
    }

    function set_endCell(c : ExampleCell) : ExampleCell
    {
        if(c != endCell && startCell != null)
        {
            for(c in p)
                c.resetCell(false);

            pfRequest.requestPath(startCell.toVector2(), c.toVector2(), callback);
        }

        endCell = c;

        return endCell;
    }
}