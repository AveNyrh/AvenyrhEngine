package avenyrh.gameObject;

import avenyrh.utils.StringUtils;
import haxe.Int64;
import avenyrh.editor.Inspector;
import avenyrh.engine.Uniq;
import avenyrh.imgui.ImGui;

@:allow(avenyrh.gameObject.GameObject)
class Component extends Uniq
{
    /**
     * Name of the component
     */
    public var name (default, null) : String;

    /**
     * Is the component enable or not
     */
    public var enable (default, set) : Bool = false;

    /**
     * GameObject this component is attached to
     */
    public var gameObject (default, set) : GameObject;

    /**
     * Is the component destroyed
     */
    @noSerial
    public var destroyed (default, null) : Bool;

    var started : Bool;

    public function new(?name : String, ?id : Null<Int64>) 
    {
        super(id);

        destroyed = false;

        if(name == null)
            this.name = StringUtils.getClass(this);
        else 
            this.name = name;

        started = false;
        enable = true;

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
    function update(dt : Float) 
    {
        if(!started)
        {
            started = true;
            start();
        }
    }

    function postUpdate(dt : Float) { }

    function fixedUpdate(dt : Float) { }

    function onEnable() { }

    function onDisable() { }

    function onDestroy() { }

    /**
     * Override this to draw custom informations on the inspector window 
     */
    function drawInfo() 
    {
        Inspector.drawInInspector(this);
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
    function removed()
    {
        enable = false;
        gameObject = null;
        destroyed = true;
        onDestroy();
    }

    function drawInspector() 
    {
        if(ImGui.collapsingHeader('$name###$name$uID', DefaultOpen))
        {
            drawInfo();
        }
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

    private function set_gameObject(go : GameObject) : GameObject 
    {
        if(gameObject != null)
            return gameObject;

        if(name == null)
            name = '${go.name} ${Type.getClassName(Type.getClass(this))}';

        gameObject = go;

        return gameObject;
    }
    //#endregion
}