package avenyrh.animation;

import avenyrh.gameObject.SpriteComponent;
import avenyrh.gameObject.GameObject;
import avenyrh.stateMachine.*;

class Animation extends State
{
    /**
     * GameObject on which this animation will change parameters
     */
    var gameObject (get, never): GameObject;

    var sprite (get, null) : Null<SpriteComponent>;

    /**
     * Animator that has this animation
     */
    var animator : Animator;

    /**
     * List of all tracks
     */
    var tracks : Array<Track>;

    /**
     * Current time of the animation
     */
    public var currentTime : Float;

    /**
     * Time max of the animation
     */
    public var length : Float;

    /**
     * Is the animation looping on itslef
     */
    public var loop : Bool;

    public function new(name : String, animator : Animator, loop : Bool = true) 
    {
        super(name, animator.stateMachine);

        this.animator = animator;

        currentTime = -0.0001;

        this.loop = loop; 

        init();
    }

    //-------------------------------
    //#region Private API
    //-------------------------------
    override function onStateEnter(info : StateChangeInfo) 
    {
        super.onStateEnter(info);

        currentTime = -0.0001;

        for(t in tracks)
            t.currentTime = -0.0001;
    }

    override function onStateUpdate(dt : Float) 
    {
        super.onStateUpdate(dt);

        //Return if not looping and at the end
        if(!loop && currentTime > length)
            return;

        currentTime += dt;

        for (t in tracks)
            t.currentTime = currentTime;

        //Reset current time if looping
        if(currentTime > length && loop)
            currentTime = -0.0001;
    }
    //#endregion

    //-------------------------------
    //#region Overridable functions
    //-------------------------------
    /**
     * Use this to init all events and/or transitions
     */
    function init() { }
    //#endregion

    //-------------------------------
    //#region Public API
    //-------------------------------
    @:noCompletion
    public function setCurrentTime(time : Float)
    {
        currentTime = time;

        for(t in tracks)
            t.currentTime = currentTime;
    }
    //#endregion

    //-------------------------------
    //#region Getters & Setters
    //-------------------------------
    inline function get_gameObject() : GameObject
    {
        return animator.gameObject;
    }

    inline function get_sprite() : Null<SpriteComponent>
    {
        if(sprite == null)
            sprite = gameObject.getComponent(SpriteComponent);

        return sprite;
    }
    //#endregion
}