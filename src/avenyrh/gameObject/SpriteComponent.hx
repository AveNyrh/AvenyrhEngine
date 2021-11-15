package avenyrh.gameObject;

import h2d.Object;
import avenyrh.editor.Inspector;
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

    override function postUpdate(dt : Float) 
    {
        super.postUpdate(dt);

        if(@:privateAccess gameObject.transformChanged)
        {
            bitmap.setPosition(gameObject.x + dx, gameObject.y + dy);
            bitmap.rotation = -gameObject.rotation - drot;
            bitmap.scaleX = gameObject.scaleX * dsx;
            bitmap.scaleY = gameObject.scaleY * dsy;
        }
    }

    override function drawInfo()
    {
        super.drawInfo();

        Inspector.image("tile", bitmap.tile);
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