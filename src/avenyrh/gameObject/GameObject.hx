package avenyrh.gameObject;

import avenyrh.imgui.ImGui;
import avenyrh.ui.Fold;
import avenyrh.engine.Inspector;
import h2d.col.Point;
import avenyrh.engine.IInspectable;
import h2d.col.Bounds;
import h2d.Graphics;
import h2d.RenderContext;
import h2d.Tile;
import h2d.Bitmap;
import avenyrh.engine.Scene;
import avenyrh.engine.IGarbageCollectable;
import avenyrh.engine.Engine;
import avenyrh.Vector2;

@:allow(avenyrh.engine.Scene, avenyrh.gameObject.Transform)
class GameObject extends Bitmap implements IGarbageCollectable implements IInspectable
{
    /**
     * Unique ID used to set each game object uID
     */
    static var UNIQ_ID = 0;
    /**
     * Scene the gameObject is on
     */
    public var scene : Scene;
    /**
     * Is the gameObject enable or not
     */
    public var enable (default, set) : Bool;
    /**
     * Unique ID of the gameObject
     */
    public var uID (default, null) : Int;
    /**
     * Simplified way to set the pivot
     */
    public var pivot (default, set) : Vector2;
    /**
     * Is the gameObject destroyed
     */
    public var destroyed (default, null) : Bool;
    /**
     * See debug lines
     */
    public var debug (default, set) : Bool;
    /**
     * Color of the debug lines
     */
    var debugColor : Int = Color.iRED;

    var debugGraphics : Null<Graphics>;

    var started : Bool;

    var components : Array<Component>;

    public function new(name : String = "", parent : h2d.Object = null, ?pivot : Vector2, ?layer : Int = 2) 
    {
        super(parent);

        uID = UNIQ_ID++;
        scene = Engine.instance.currentScene;
        
        destroyed = false;
        components = [];
        children = [];

        this.name = name;

        if(pivot == null)
            this.pivot = Pivot.CENTER;
        else
            this.pivot = pivot;

        scene.addGameObject(this, layer);
        
        init();

        enable = true;
    }

    //-------------------------------
    //#region Overridable functions
    //-------------------------------
    /**
     * Use this to initialize components and else
     */
    function init() { }

    /**
     * Called on the first frame \
     * Use this to do things after everything is initialized
     */
    function start() { }

    /**
     * Main loop
     */
    function update(dt : Float) { }

    /**
     * Loop after the main loop
     */
    function postUpdate(dt : Float) { }

    function onEnable() 
    {
        for(child in children)
        {
            if(Std.isOfType(child, GameObject))
            {
                var go : GameObject = cast(child);
                go.enable = true;
            }
        }
    }

    function onDisable() 
    { 
        for(child in children)
        {
            if(Std.isOfType(child, GameObject))
            {
                var go : GameObject = cast(child);
                go.enable = false;
            }
        }
    }

    function onDestroy() { }

    override function removeChildren()
    {
        for(child in children)
            if(Std.isOfType(child, GameObject))
                scene.removeGameObject(cast child);

        super.removeChildren();
    }

    /**
     * Called when the screen is resized
     */
    function onResize() { }

    /**
     * Override this to draw custom informations on the inspector window 
     */
    function drawInfo() { }
    //#endregion

    //-------------------------------
    //#region Public API
    //-------------------------------
    /**
     * Gets the first component found on this gameObject
     * @param component Class of the wanted component
     */
    public function getComponent<T : Component>(componentType : Class<T>) : T
    {
        for(c in components)
        {
            if(Std.isOfType(c, componentType))
            {
                return cast c; 
            }
        }

        return null;
    }

    /**
     * Gets the all components found on this gameObject
     * @param componentType Class of the wanted components
     */
    public function getComponents<T : Component>(componentType : Class<T>) : Array<T>
    {
        var cs : Array<T> = [];

        for(c in components)
        {
            if(Std.isOfType(c, componentType))
            {
                cs.push(cast c);
            }
        }

        return cs;
    }

    /**
     * Returns a component by its name
     * @param name Name of the wanted component
     * @return Component
     */
    public function getComponentByName(name : String) : Component
    {
        for(c in components)
        {
            if(c.name == name)
                return c;
        }

        return null;
    }

    /**
     * Adds a component to this gameObject
     * @param component Component to add
     */
    public function addComponent(component : Component) : Component
    {
        components.push(component);

        return component;
    }

    /**
     * Removes a component on this gameObject
     * @param component Component to remove
     */
    public function removeComponent(component : Component) 
    {
        if(!hasComponent(component) || component == null)
            return;

        components.remove(component);
        component.removed();
    }

    /**
     * Returns true if this gameObject has the component attached to it
     * @param component Wanted component
     * @return True if it contains, false if not
     */
    public function hasComponent(component : Component) : Bool 
    {
        if(component == null)
            throw '[GameObject ${name}] : Parameter can not be null';

        for(c in components)
            if(c.uID == component.uID)
                return true;
        
        return false;
    }

    /**
     * Returns true if this gameObject has the child in its children
     * @param child Wanted gameObject
     * @return True if it contains, false if not
     */
    public function hasChild(child : GameObject) : Bool 
    {
        if(child == null)
            throw '[GameObject ${name}] : Parameter can not be null';
    
        for(c in children)
        {
            if(Std.isOfType(c, GameObject))
            {
                var go : GameObject = cast c;

                if(go.uID == child.uID)
                    return true;
            }
        }
            
        return false;
    }

    /**
     * Changes the tile and keep the same pivot
     * @param tile 
     */
    public function changeTile(t : Tile) 
    {
        tile = t;
        
        set_pivot(pivot);
    }

    public override function toString() : String 
    {
        return name + " : " + uID;
    }
    //#endregion

    //-------------------------------
    //#region Private API
    //-------------------------------
    /**
     * Called by the scene to update
     */
    @:noCompletion
    private function _update(dt : Float)
    {
        if(!enable || destroyed)
            return;

        if(!started)
        {
            started = true;
            start();
        }

        update(dt);

        if(!enable || destroyed)
            return;

        for (c in components) 
            c.update(dt);
    }

    /**
     * Called by the scene after the update
     */
    @:noCompletion
    private function _postUpdate(dt : Float)
    {
        if(!enable || destroyed)
            return;

        postUpdate(dt);

        if(!enable || destroyed)
            return;

        for (c in components)
            if(c.enable)
                c.postUpdate(dt);
    }

    /**
     * Called by the scene when this gameObject gets removed from it
     */
    @:noCompletion
    private function removed() 
    {
        for (c in components) 
            c.removed();

        removeChildren();

        enable = false;

        Engine.instance.gc.push(this);
    }

    /**
     * GarbageCollectable implementation \
     * Destroys this gameObject and its components
     */
    @:noCompletion
    private function onDispose()
    {
        for(c in components)
            if(!c.destroyed)
                removeComponent(c);

        destroyed = true;
        onDestroy();
    }

    @:noCompletion
    public function drawInspector()
    {
        //Position
        var pos : Array<Float> = [x, y];
        Inspector.dragFields("Position", uID, pos, 0.1);
        x = pos[0];
        y = pos[1];
    
        //Rotation
        var rot : Array<Float> = [AMath.toDeg(rotation)];
        Inspector.dragFields("Rotation", uID, rot, 0.1);
        rotation = AMath.toRad(rot[0]);

        //Scale
        var scale : Array<Float> = [scaleX, scaleY];
        Inspector.dragFields("Scale", uID, scale, 0.1);
        scaleX = scale[0];
        scaleY = scale[1];

        drawInfo();

        for(c in components)
            c.drawInspector();
    }

    override function draw(ctx : RenderContext) 
    {
        if(enable)
        {
            super.draw(ctx);

            if(debug)
            {
                debugGraphics.lineStyle(1, debugColor);
                var bds : Bounds = new Bounds();
                getBoundsRec(this, bds, true);
                debugGraphics.drawRect(bds.xMin, bds.yMin, bds.width, bds.height);
            }
        }
    }
    //#endregion

    //-------------------------------
    //#region Getters & Setters
    //-------------------------------
    function set_enable(enable : Bool) : Bool
    {
        if(this.enable == enable)
            return this.enable;

        this.enable = enable;
        
        if(enable)
            onEnable();
        else 
            onDisable();

        return this.enable;
    }

    function set_pivot(p : Vector2) : Vector2
    {
        pivot = p;

        if(tile != null)
        {
            tile.dx = pivot.x * tile.width;
            tile.dy = pivot.y * tile.width;
        }

        return pivot;
    }

    function set_debug(value : Bool) : Bool
    {
        debug = value;

        if(debug)
            debugGraphics = new Graphics(this);
        else
        {
            if(debugGraphics == null)
                return debug;
            
            debugGraphics.clear();
            debugGraphics = null;
        }

        return debug;
    }
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