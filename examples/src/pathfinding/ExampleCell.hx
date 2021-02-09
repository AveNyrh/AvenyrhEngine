package examples.src.pathfinding;

import avenyrh.Vector2;
import h2d.Interactive;
import avenyrh.Color;
import h2d.Tile;
import h2d.Object;
import h2d.Bitmap;
import avenyrh.pathfinding.Cell;

class ExampleCell extends Cell
{
    /**
     * Current cell being hovered
     */
    public static var currentHoverCell : ExampleCell;

    public var bitmap : Bitmap;

    var interactive : Interactive;

    public var idle : Tile;

    public var hover : Tile;

    public var occupied : Tile;

    public var unwalkable : Tile;

    public var start : Tile;

    public var end : Tile;

    public var state : ExampleCellState;

    var scene : PFScene;

    public function new(x : Int, y : Int, size : Int, parent : Object, scene : PFScene)
    {
        super(x, y);

        this.scene = scene;

        var tileSize : Int = Std.int(size * 0.9);

        //Tiles
        idle = Tile.fromColor(Color.iDARKGREY, tileSize, tileSize);
        hover = Tile.fromColor(Color.iLIGHTGREY, tileSize, tileSize);
        occupied = Tile.fromColor(Color.iLIMEGREEN, tileSize, tileSize);
        unwalkable = Tile.fromColor(Color.iRED, tileSize, tileSize);
        start = Tile.fromColor(Color.iBLUE, tileSize, tileSize);
        end = Tile.fromColor(Color.iGREEN, tileSize, tileSize);

        bitmap = new Bitmap(idle, parent);
        bitmap.setPosition(x * size, y * size);

        interactive = new Interactive(tileSize, tileSize, bitmap);
        interactive.onOver = onOver;
        interactive.onOut = onOut;

        state = Idle;
    }

    function onOver(e : hxd.Event)
    {
        currentHoverCell = this;

        if(state == Idle)
        {
            if(scene.startCell == null)
                bitmap.tile = hover;
            else 
            {
                bitmap.tile = end;
                scene.endCell = this;
            }
        }
    }

    function onOut(e : hxd.Event)
    {
        if(state == Idle)
        {
            bitmap.tile = idle;
        }
    }

    public function resetCell(hardReset : Bool)
    {
        if(state == Occupied || ((state == Locked || state == Unwalkable) && hardReset))
        {
            state = Idle;
            bitmap.tile = idle;

            if(hardReset)
                isWalkable = true;
        }
    }

    public inline function toVector2() : Vector2
    {
        return new Vector2(x, y);
    }
}

enum ExampleCellState
{
    Idle;
    Occupied;
    Unwalkable;
    Locked;
}