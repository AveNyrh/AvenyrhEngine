package avenyrh.gameObject;

import avenyrh.ui.Fold;
import avenyrh.engine.Inspector;
import avenyrh.engine.IGarbageCollectable;
import avenyrh.engine.Engine;

@:allow(avenyrh.gameObject.GameObject)
class Component implements IGarbageCollectable
{
    /**
     * Unique ID used to set each component uID
     */
    static var UNIQ_ID = 0;

    /**
     * Name of the component
     */
    public var name (default, null) : String;
    /**
     * Is the component enable or not
     */
    public var enable (default, set) : Bool = false;
    /**
     * Unique ID of the component
     */
    public var uID (default, null) : Int;
    /**
     * GameObject this component is attached to
     */
    public var gameObject (default, null) : GameObject;
    /**
     * Is the component destroyed
     */
    public var destroyed (default, null) : Bool;

    private var started : Bool;

    public function new(gameObject : GameObject, name : String) 
    {
        destroyed = false;
        uID = UNIQ_ID++;
        this.name = name;
        this.gameObject = gameObject;
        started = false;

        init();

        this.gameObject = gameObject;
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
    function update(dt : Float) 
    {
        if(!enable || destroyed)
            return;

        if(!started)
        {
            started = true;
            start();
        }
    }

    function postUpdate(dt : Float) { if(!enable || destroyed) return; }
        
    function removed()
    {
        enable = false;
        Engine.instance.gc.push(this);
    }

    function onEnable() { }

    function onDisable() { }

    function onDestroy() { }

    /**
     * Override this to draw custom informations on the inspector window 
     * Call super and append to it
     */
    function drawInfo(inspector : Inspector, fold : Fold) 
    {
        inspector.space(fold, 10);

        //var n : Array<String> = Type.getClassName(Type.getClass(this)).split(".");
        inspector.textLabel(fold, '-- $name --');
    }
    //#endregion

    //-------------------------------
    //#region Public API
    //-------------------------------
    /**
     * Gets a component that is on the same gameObject
     * @param componentType Class of the wanted component
     */
    public function getComponent<T : Component>(componentType : Class<T>) : T
    {
        return gameObject.getComponent(componentType);
    }

    /**
     * Gets all components that are on the same gameObject
     * @param componentType Class of the wanted component
     */
    public function getComponents<T : Component>(componentType : Class<T>) : Array<T>
    {
        return gameObject.getComponents(componentType);
    }

    /**
     * Adds a component to the same gameObject as this one
     * @param componentType Class of the component to add
     */
    public function addComponent(component : Component)
    {
        return gameObject.addComponent(component);
    }

    /**
     * Removes a component that is on the same gameObject as this one
     * @param component Component to remove
     */
    public function removeComponent(component : Component)
    {
        gameObject.removeComponent(component);
    }

    public function toString() : String 
    {
        return name + " : " + uID;
    }
    //#endregion

    //-------------------------------
    //#region Private API
    //-------------------------------
    /**
     * GarbageCollectable implementation \
     * Destroys this component
     */
     private function onDispose() 
    {
        gameObject = null;
        destroyed = true;
        onDestroy();
    }
    //#endregion

    //-------------------------------
    //#region Getters & Setters
    //-------------------------------
    private function set_enable(enable : Bool) : Bool
    {
        if(this.enable == enable)
            return this.enable;
        
        this.enable = enable;

        enable ? onEnable() : onDisable();

        return this.enable;
    }
    //#endregion
}