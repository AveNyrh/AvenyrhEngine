package avenyrh.gameObject;

import h2d.Object;
using Lambda;
import haxe.Int64;
import avenyrh.engine.Uniq;
import avenyrh.imgui.ImGui;
import avenyrh.editor.Inspector;
import avenyrh.editor.IInspectable;
import avenyrh.scene.SceneManager;
import avenyrh.scene.Scene;

@:allow(avenyrh.scene.Scene, avenyrh.gameObject.Transform)
class GameObject extends Uniq implements IInspectable
{
    /**
     * Scene the gameObject is on
     */
    @noSerial
    @hideInInspector
    public var scene : Scene;

    /**
     * Is the gameObject destroyed
     */
    @noSerial
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
     * Local X position
     * 
     * Relative to its parent
     */
    @hideInInspector
    public var x (get, set) : Float;

    /**
     * Absolute X position
     */
    @hideInInspector
    public var absX (get, never) : Float;

    /**
     * Local Y position
     * 
     * Relative to its parent
     */
    @hideInInspector
    public var y (get, set) : Float;

    /**
     * Absolute Y position
     */
    @hideInInspector
    public var absY (get, never) : Float;

    /**
     * Local rotation
     * 
     * Relative to its parent
     */
    @hideInInspector
    public var rotation (get, set) : Float;

    /**
     * Absolute rotation
     */
    @hideInInspector
    public var absRotation (get, never) : Float;

    /**
     * Local scale along the x axis
     * 
     * Relative to its parent
     */
    @hideInInspector
    public var scaleX (get, set) : Float;

    /**
     * Absolute scale along the x axis
     * 
     * Relative to its parent
     */
    @hideInInspector
    public var absScaleX (get, never) : Float;

    /**
     * Scale along the y axis
     */
    @hideInInspector
    public var scaleY (get, set) : Float;

    /**
     * Absolute scale along the y axis
     * 
     * Relative to its parent
     */
    @hideInInspector
    public var absScaleY (get, never) : Float;
    
    @noSerial
    @hideInInspector
    public var parent (default, set) : Null<GameObject>;

    @hideInInspector
    public var children (default, null) : Array<GameObject>;

    var obj (default, set) : Object = null;

    var started : Bool = false;

    @serializable
    var components : Array<Component>;

    public function new(name : String = "", parent : GameObject = null, ?scene : Scene, ?id : Null<Int64>) 
    {
        super(id);

        if(scene == null)
            this.scene = SceneManager.currentScene;
        else
            this.scene = scene;

        destroyed = false;
        components = [];
        children = [];

        this.name = name;
        this.parent = parent;
        enable = true;

        obj = new Object(parent == null ? this.scene.scroller : parent.obj);

        this.scene.addGameObject(this);
        
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
        //Name
        ImGui.spacing();
        ImGui.spacing();
        var availableSpace : ImVec2 = ImGui.getContentRegionAvail();
        var input_text_buffer = new hl.Bytes(128);
        input_text_buffer = @:privateAccess name.toUtf8();
        if (ImGui.inputText('##name$uID', input_text_buffer, 128)) 
        {
            var st = @:privateAccess String.fromUTF8(input_text_buffer);
            //name = st;
        }
        var plusButtonSize : Int = 19;
        var lockButtonSize : Int = 60;
        ImGui.sameLine(availableSpace.x - plusButtonSize / 2 - lockButtonSize - 16);
        if(ImGui.button('+##${uID}', {x : plusButtonSize, y : plusButtonSize}))
            ImGui.openPopup('GameObjectSettings##${uID}');
        ImGui.sameLine();
        if(Inspector.locked)
        {
            ImGui.pushStyleColor(Text, Color.iBLACK);
            ImGui.pushStyleColor(Button, Color.iWHITE);
            ImGui.pushStyleColor(ButtonHovered, Color.iWHITE);
            ImGui.pushStyleColor(ButtonActive, Color.iWHITE);
            if(ImGui.button('Unlock##${uID}', {x : lockButtonSize, y : plusButtonSize}))
                Inspector.locked = false;
            ImGui.popStyleColor(4);
        }
        else 
        {
            if(ImGui.button('Lock##${uID}', {x : lockButtonSize, y : plusButtonSize}))
                Inspector.locked = true;
        }

        ImGui.spacing();
        ImGui.spacing();
        ImGui.separator();
        ImGui.spacing();
        ImGui.spacing();

        //Pop up for the "+" button
        if(ImGui.beginPopup('GameObjectSettings##${uID}'))
        {
            if(ImGui.menuItem("Reset transform"))
            {
                x = 0;
                y = 0;
                rotation = 0;
                scaleX = 1;
                scaleY = 1;
            }

            ImGui.endPopup();
        }

        //Enable
        var e : Bool = Inspector.checkbox("Enable", uID, enable);
        enable = e;

        //Position      
        var pos : Vector2 = new Vector2(x, y);
        pos = Inspector.dragVector2("Position", uID, pos);
        x = pos.x;
        y = pos.y;

        //Rotation
        var rot : Array<Float> = [AMath.toDeg(rotation)];
        Inspector.dragFloats("Rotation", uID, rot, 0.1);
        rotation = AMath.toRad(rot[0]);

        //Scale
        var scale : Vector2 = new Vector2(scaleX, scaleY);
        scale = Inspector.dragVector2("Scale", uID, scale, 0.1, 1);
        scaleX = scale.x;
        scaleY = scale.y;

        ImGui.spacing();

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
        obj.setPosition(x, y);
    }

    /**
     * Moves by the specified amount
     */
    public inline function move(dx : Float, dy : Float)
    {
        obj.x += dx;
        obj.y += dy;
    }

    /**
     * Moves by the specified amount, takes in count the rotation
     */
    public inline function moveWithRotation(dx : Float, dy : Float)
    {
        obj.move(dx, dy);
    }

    /**
     * Rotates by the specified angle
     */
    public inline function rotate(a : Float) 
    {
		obj.rotate(-a);
	}

    /**
     * Scales on both X and Y by the specified value
     */
    public inline function scale(s : Float) 
    {
		obj.scale(s);
	}

    /**
     * Sets the scale on both X and Y to the specified value
     */
    public inline function setScale(s : Float) 
    {
		obj.setScale(s);
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
    public inline function getComponentByName(name : String) : Component
    {
        return components.find((c) -> c.name == name);
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
        if(!children.contains(go))
        {
            children.push(go);
            go.parent = this;
        }
    }

    /**
     * Removes specified child
     * 
     * Same as calling child.destroy()
     */
    public function removeChild(go : GameObject)
    {
        if(children.contains(go))
        {
            children.remove(go);
            go.parent = null;
        }
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

    public function getParentRec() : Array<GameObject>
    {
        var arr : Array<GameObject> = [];
        var p : GameObject = parent;
        while (p != null)
        {
            arr.push(p);
            p = p.parent;
        }

        return arr;
    }
    //#endregion

    /**
     * Destroys this gameObject, its children and its components
     */
    public function destroy()
    {
        if(parent != null)
            parent.removeChild(this);
        else
            removed();
    }

    public function toString() : String 
    {
        return '[${Int64.toStr(uID)}]$name';
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

    inline function get_x() : Float
    {
        return obj.x;
    }

    inline function set_x(x : Float) : Float
    {
        return obj.x = x;
    }

    inline function get_absX() : Float
    {
        return @:privateAccess (obj.absX - scene.scroller.x) / scene.scroller.scaleX;
    }

    inline function get_y() : Float
    {
        return obj.y;
    }

    inline function set_y(y : Float) : Float
    {
        return obj.y = y;
    }

    inline function get_absY() : Float
    {
        return @:privateAccess (obj.absY - scene.scroller.y) / scene.scroller.scaleY;
    }

    inline function get_rotation() : Float
    {
        return -obj.rotation;
    }

    inline function set_rotation(r : Float) : Float
    {
        return obj.rotation = -r;
    }

    inline function get_absRotation() : Float
    {
        return obj.rotation;
    }

    inline function get_scaleX() : Float
    {
        return obj.scaleX;
    }

    inline function set_scaleX(s : Float) : Float
    {
        return obj.scaleX = s;
    }

    inline function get_absScaleX() : Float
    {
        return @:privateAccess obj.getAbsPos().getScale().x;
    }

    inline function get_scaleY() : Float
    {
        return obj.scaleY;
    }

    inline function set_scaleY(s : Float) : Float
    {
        return obj.scaleY = s;
    }

    inline function get_absScaleY() : Float
    {
        return @:privateAccess obj.getAbsPos().getScale().y;
    }

    function set_obj(o : Object) : Object
    {
        if(obj != null)
        {
            //Attach children to the new object
            for(child in children)
                o.addChild(child.obj);

            //Set new object data 
            o.setPosition(obj.x, obj.y);
            o.rotation = obj.rotation;
            o.scaleX = obj.scaleX;
            o.scaleY = obj.scaleY;
            o.alpha = obj.alpha;
            o.visible = obj.visible;

            //Attach the new object to the parent at the right index
            obj.parent.addChildAt(o, obj.parent.getChildIndex(obj));
            obj.parent.removeChild(obj);
        }

        return obj = o;
    }

    function set_parent(p : Null<GameObject>) : Null<GameObject>
    {  
        if(p != null)
        {
            if(parent != null)
            {
                parent.children.remove(this);

                if(obj != null)
                    parent.obj.removeChild(obj);
            }
            else if(@:privateAccess scene.rootGO.contains(this))
                @:privateAccess scene.rootGO.remove(this);

            parent = p;

            if(!parent.children.contains(this))
                parent.children.push(this);
            
            if(obj != null)
                parent.obj.addChild(obj);
        }
        else
        {
            parent = null;
            
            if(@:privateAccess !scene.rootGO.contains(this))
                @:privateAccess scene.rootGO.push(this);

            if(obj != null)
            {
                if(obj.parent != null)
                    obj.parent.removeChild(obj);
                scene.scroller.addChild(obj);
            }
        }

        return parent;
    }
    //#endregion
}