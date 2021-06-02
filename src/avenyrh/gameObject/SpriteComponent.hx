package avenyrh.gameObject;

import h2d.Object;
import avenyrh.engine.Inspector;
import h2d.Tile;
import h2d.Bitmap;

class SpriteComponent extends GraphicComponent 
{
    /**
     * Actual graphic object
     */
    public var bitmap (default, null) : Bitmap;

    /**
     * Simplified way to set the pivot
     */
    public var pivot (default, set) : Vector2;

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
    public var layer (default, null) : Int;

    public var tile (get, set) : Tile;

    override public function new(?name : String, ?parent : Object, ?tile : Tile, ?layer : Int = 0, ?pivot : Vector2) 
    {
        super(name == null ? "Sprite" : name);

        this.layer = layer;
        bitmap = new Bitmap(tile, parent);
    }

    override function postUpdate(dt : Float) 
    {
        super.postUpdate(dt);

        if(@:privateAccess gameObject.transformChanged)
        {
            bitmap.setPosition(gameObject.x + dx, gameObject.y + dy);
            bitmap.rotation = gameObject.rotation + drot;
            bitmap.scaleX = gameObject.scaleX * dsx;
            bitmap.scaleY = gameObject.scaleY * dsy;
        }
    }

    override function drawInfo()
    {
        super.drawInfo();

        Inspector.image("Tile", bitmap.tile);
    }

    //-------------------------------
    //#region Getters & Setters
    //-------------------------------
    inline function set_pivot(p : Vector2) : Vector2
    {
        pivot = p;

        if(bitmap.tile != null)
        {
            bitmap.tile.dx = pivot.x * bitmap.tile.width;
            bitmap.tile.dy = pivot.y * bitmap.tile.width;
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

    override function set_gameObject(go : GameObject) : GameObject 
    {
        if(gameObject != null)
            return gameObject;

        if(bitmap.parent != null)
            return super.set_gameObject(go);

        var p : GameObject = go;
        var graph : Null<GraphicComponent>;
        var added : Bool = false;
        while(p != null)
        {
            p = p.parent;

            if(p == null)
                break;

            graph = p.getComponent(GraphicComponent);

            if(graph != null)
            {
                graph.getObject().addChild(bitmap);
                added = true;
                break;
            }
        }

        if(!added)
            go.scene.scroller.addChildAt(bitmap, layer);

        if(pivot != null)
            this.pivot = pivot;
        else
            this.pivot = Pivot.CENTER;
        return super.set_gameObject(go);
    }

    public function getObject() : Object { return bitmap; } 
    //#endregion
}

class Pivot
{
    /**
     * Sets the pivot to the center of the tile
     */
    public static var CENTER (get, never) : Vector2;

    private static function get_CENTER() : Vector2 
    {
        return Vector2.ONE / -2;
    }

    /**
     * Sets the pivot to the up left of the tile
     */
    public static var UP_LEFT (get, never) : Vector2;

    private static function get_UP_LEFT() : Vector2 
    {
        return Vector2.ZERO;
    }

    /**
     * Sets the pivot to the up right of the tile
     */
    public static var UP_RIGHT (get, never) : Vector2;

    private static function get_UP_RIGHT() : Vector2 
    {
        return Vector2.LEFT;
    }

    /**
     * Sets the pivot to the down left of the tile
     */
    public static var DOWN_LEFT (get, never) : Vector2;

    private static function get_DOWN_LEFT() : Vector2 
    {
        return Vector2.DOWN;
    }

    /**
     * Sets the pivot to the down right of the tile
     */
    public static var DOWN_RIGHT (get, never) : Vector2;

    private static function get_DOWN_RIGHT() : Vector2 
    {
        return -1 * Vector2.ONE;
    }

    /**
     * Sets the pivot to the up center of the tile
     */
    public static var UP (get, never) : Vector2;

    private static function get_UP() : Vector2 
    {
        return Vector2.LEFT / 2;
    }

    /**
     * Sets the pivot to the down center of the tile
     */
    public static var DOWN (get, never) : Vector2;

    private static function get_DOWN() : Vector2 
    {
        return Vector2.DOWN + Vector2.LEFT / 2;
    }

    /**
     * Sets the pivot to the left center of the tile
     */
    public static var LEFT (get, never) : Vector2;

    private static function get_LEFT() : Vector2 
    {
        return Vector2.DOWN / 2;
    }

    /**
     * Sets the pivot to the right center of the tile
     */
    public static var RIGHT (get, never) : Vector2;

    private static function get_RIGHT() : Vector2 
    {
        return Vector2.LEFT + Vector2.DOWN / 2;
    }
}