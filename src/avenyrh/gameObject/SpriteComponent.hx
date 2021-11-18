package avenyrh.gameObject;

import h2d.Object;
import avenyrh.editor.Inspector;
import h2d.Tile;
import h2d.Bitmap;

class SpriteComponent extends Component 
{
    /**
     * Actual graphic object
     */
    public var bitmap (default, null) : Bitmap;

    /**
     * Simplified way to set the pivot
     */
    public var pivot (default, set) : Pivot;

    /**
     * Delta position on the X axis
     */
    @hideInInspector
    public var dx : Float = 0;

    /**
     * Delta position on the Y axis
     */
    @hideInInspector
    public var dy : Float = 0;

    /**
     * Delta rotation
     */
    @hideInInspector
    public var drot : Float = 0;

    /**
     * Delta scale on the X axis
     */
    @hideInInspector
    public var dsx : Float = 1;

    /**
     * Delta scale on the Y axis
     */
    @hideInInspector
    public var dsy : Float = 1;

    public var alpha (get, set) : Float;

    public var visible (get, set) : Bool;

    @hideInInspector
    public var layer (default, null) : Int; //Change this to set this in the inspector

    public var tile (get, set) : Tile;

    override public function new(?name : String, ?parent : Object) 
    {
        super(name == null ? "SpriteComponent" : name);

        var t = Tile.fromColor(Color.iWHITE, 10, 10, 1);
        bitmap = new Bitmap(t, parent);
        pivot = CENTER;
    }

    override function drawInfo()
    {
        super.drawInfo();

        //Alpha
        var a : Array<Float> = [alpha];
        Inspector.sliderFloats("Alpha", uID, a, 0, 1);
        alpha = a[0];

        bitmap.color = Inspector.colorPicker("Color", uID, bitmap.color);
    }

    override function onDestroy() 
    {
        super.onDestroy();

        bitmap.remove();
    }

    //-------------------------------
    //#region Getters & Setters
    //-------------------------------
    public function getPivot() : Vector2
    {
        return switch (pivot)
        {
            case CENTER     : Vector2.ONE / -2;
            case UP         : Vector2.LEFT / 2;
            case DOWN       : Vector2.DOWN + Vector2.LEFT / 2;
            case LEFT       : Vector2.DOWN / 2;
            case RIGHT      : Vector2.LEFT + Vector2.DOWN / 2;
            case UP_LEFT    : Vector2.ZERO;
            case UP_RIGHT   : Vector2.LEFT;
            case DOWN_LEFT  : Vector2.DOWN;
            case DOWN_RIGHT : -1 * Vector2.ONE;
        }
    }

    inline function set_pivot(p : Pivot) : Pivot
    {
        pivot = p;

        if(bitmap.tile != null)
        {
            bitmap.tile.dx = getPivot().x * bitmap.tile.width;
            bitmap.tile.dy = getPivot().y * bitmap.tile.width;
        }

        return pivot;
    }

    inline function get_alpha() : Float
    {
        return bitmap.alpha;
    }

    inline function set_alpha(a : Float) : Float
    {
        bitmap.alpha = a;

        return bitmap.alpha;
    }

    inline function get_visible() : Bool
    {
        return bitmap.visible;
    }

    inline function set_visible(v : Bool) : Bool
    {
        bitmap.visible = v;

        return bitmap.visible;
    }

    inline function get_tile() : Tile
    {
        return bitmap.tile;
    }

    inline function set_tile(t : Tile) : Tile
    {
        bitmap.tile = t;
            
        set_pivot(pivot);

        return bitmap.tile;
    }

    override function set_gameObject(go : GameObject) : GameObject @:privateAccess
    {
        go.obj = bitmap;

        if(gameObject != null)
        {
            gameObject.obj = new Object();
        }

        return super.set_gameObject(go);
    }
    //#endregion
}

enum Pivot  
{
    /**
     * Sets the pivot to the center of the tile
     */
    CENTER;
    /**
     * Sets the pivot to the up center of the tile
     */
    UP;
    /**
     * Sets the pivot to the down center of the tile
     */
    DOWN;
    /**
     * Sets the pivot to the left center of the tile
     */
    LEFT;
    /**
     * Sets the pivot to the right center of the tile
     */
    RIGHT;
    /**
     * Sets the pivot to the up left of the tile
     */
    UP_LEFT;
    /**
     * Sets the pivot to the up right of the tile
     */
    UP_RIGHT;
    /**
     * Sets the pivot to the down left of the tile
     */
    DOWN_LEFT;
    /**
     * Sets the pivot to the down right of the tile
     */
    DOWN_RIGHT;
}