package avenyrh.gameObject;

using Lambda;
import avenyrh.engine.Uniq;
import avenyrh.imgui.ImGui;
import avenyrh.engine.Inspector;
import avenyrh.engine.IInspectable;
import avenyrh.engine.Scene;
import avenyrh.engine.Engine;

@:rtti
@:allow(avenyrh.engine.Scene, avenyrh.gameObject.Transform)
class GameObject extends Uniq implements IInspectable
{
    /**
     * Scene the gameObject is on
     */
    @hideInInspector
    public var scene : Scene;

    /**
     * Is the gameObject destroyed
     */
    @hideInInspector
    public var destroyed (default, null) : Bool;

    /**
     * Is the gameObject enable or not
     */
    @hideInInspector
    public var enable (default, set) : Bool;

    /**
     * Name of the GameObject
     */
    @hideInInspector
    public var name (default, null) : String;

    /**
     * X position
     */
    @hideInInspector
    public var x (default, set) : Float = 0;

    /**
     * Y position
     */
    @hideInInspector
    public var y (default, set) : Float = 0;

    /**
     * Current rotation
     */
    @hideInInspector
    public var rotation (default, set) : Float = 0;

    /**
     * Scale along the x axis
     */
    @hideInInspector
    public var scaleX (default, set) : Float = 1;

    /**
     * Scale along the y axis
     */
    @hideInInspector
    public var scaleY (default, set) : Float = 1;

    @hideInInspector
    public var parent (default, set) : Null<GameObject>;

    @hideInInspector
    public var children (default, null) : Array<GameObject>;

    var started : Bool = false;

    var transformChanged : Bool = false;

    var components : Array<Component>;

    public function new(name : String = "", parent : GameObject = null) 
    {
        uID = Uniq.UNIQ_ID++;
        scene = Engine.instance.currentScene;
        
        destroyed = false;
        components = [];
        children = [];

        this.name = name;
        this.parent = parent;
        enable = true;

        scene.addGameObject(this);
        
        init();
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

    /**
     * Called at a fixed interval
     */
    function fixedUpdate(dt : Float) { }

    function onEnable() 
    {
        for(child in children)
        {
            child.enable = true;
        }
    }

    function onDisable() 
    { 
        for(child in children)
        {
            child.enable = false;
        }
    }

    function onDestroy() { }

    /**
     * Called when the screen is resized
     */
    function onResize() { }

    /**
     * Override this to draw custom informations on the inspector window \
     * Remove super call to disable automatic fields display
     */
    function drawInfo() 
    { 
        //Enable
        var e : Bool = Inspector.checkbox("Enable", uID, enable);
        enable = e;

        //Position
        var pos : Array<Float> = [x, y];
        Inspector.dragFloats("Position", uID, pos, 0.1);
        x = pos[0];
        y = pos[1];
    
        //Rotation
        var rot : Array<Float> = [AMath.toDeg(rotation)];
        Inspector.dragFloats("Rotation", uID, rot, 0.1);
        rotation = AMath.toRad(rot[0]);

        //Scale
        var scale : Array<Float> = [scaleX, scaleY];
        Inspector.dragFloats("Scale", uID, scale, 0.1);
        scaleX = scale[0];
        scaleY = scale[1];

        ImGui.separator();

        Inspector.drawInInspector(this);
    }
    //#endregion

    //-------------------------------
    //#region Public API
    //-------------------------------
    //#region Transform
    /**
     * Sets the current position relative to its parent
     */
    public inline function setPosition(x : Float, y : Float)
    {
        this.x = x;
        this.y = y;

        transformChanged = true;
    }

    /**
     * Moves by the specified amount, takes in count the rotation
     */
    public function move(dx : Float, dy : Float)
    {
        x += dx * Math.cos(rotation);
		y += dy * Math.sin(rotation);

        transformChanged = true;
    }

    /**
     * Rotates by the specified angle
     */
    public inline function rotate(a : Float) 
    {
		rotation += a;

        transformChanged = true;
	}

    /**
     * Scales on both X and Y by the specified value
     */
    public inline function scale(s : Float) 
    {
		scaleX *= s;
		scaleY *= s;

        transformChanged = true;
	}

    /**
     * Sets the scale on both X and Y to the specified value
     */
    public inline function setScale(s : Float) 
    {
		scaleX = s;
		scaleY = s;

        transformChanged = true;
	}
    //#endregion
    
    //#region Components
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
        component.gameObject = this;

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
    //#endregion

    //#region Children
    public function addChild(go : GameObject)
    {
        children.push(go);
        go.parent = this;
    }

    /**
     * Removes all children
     */
    public function removeChildren()
    {
        for(c in children)
            c.removed();

        children = [];
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
    //#endregion

    public function toString() : String 
    {
        return '[$uID]$name';
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
            if(c.enable || !c.destroyed)
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
            if(c.enable || !c.destroyed)
                c.postUpdate(dt);

        transformChanged = false;
    }

    /**
     * Called by the scene at a fixed interval
     */
    @:noCompletion
    private function _fixedUpdate(dt : Float)
    {
        if(!enable || destroyed)
            return;

        fixedUpdate(dt);

        if(!enable || destroyed)
            return;

        for (c in components)
            if(c.enable || !c.destroyed)
                c.fixedUpdate(dt);
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
        destroyed = true;
        onDestroy();
    }

    @:noCompletion
    public function drawInspector()
    {
        drawInfo();

        for(c in components)
        {
            ImGui.spacing();
            c.drawInspector();
        }
    }

    @:noCompletion
    public function drawHierarchy() : Null<IInspectable>
    {
        var inspec : Null<IInspectable> = null;
        var i : Null<IInspectable> = null;

        if(ImGui.selectable('$name###$name$uID', this == Inspector.currentInspectable))
            inspec = this;

        for(c in children)
        {
            var ci : IInspectable = c.drawHierarchy();

            if(ci != null && i == null)
                i = ci;
        }

        if(i != null && inspec == null)
            inspec = i;

        return inspec;
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

    function set_x(x : Float) : Float
    {
        this.x = x;

        transformChanged = true;

        return x;
    }

    function set_y(y : Float) : Float
    {
        this.y = y;

        transformChanged = true;

        return y;
    }

    function set_rotation(r : Float) : Float
    {
        rotation = r;

        transformChanged = true;

        return rotation;
    }

    function set_scaleX(s : Float) : Float
    {
        scaleX = s;

        transformChanged = true;

        return scaleX;
    }

    function set_scaleY(s : Float) : Float
    {
        scaleY = s;

        transformChanged = true;

        return scaleY;
    }

    function set_parent(p : Null<GameObject>) : Null<GameObject>
    {
        if(p != null)
        {
            parent = p;
            parent.children.push(this);
        }
        else
            parent = null;

        return parent;
    }
    //#endregion
}