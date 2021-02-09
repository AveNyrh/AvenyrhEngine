package avenyrh.animation;

import avenyrh.gameObject.GameObject;
import avenyrh.stateMachine.*;

class Animation extends State
{
    /**
     * GameObject on which this animation will change parameters
     */
    var gameObject(get, never): GameObject; inline function get_gameObject() return animator.gameObject;
    /**
     * Animator that has this animation
     */
    var animator : Animator;
    /**
     * List of all events
     */
    var events : Array<EventKey>;
    /**
     * Current time of the animation
     */
    public var currentTime (default, null) : Float;
    /**
     * Time at the last frame
     */
    var oldTime : Float;
    /**
     * Time max of the animation
     */
    public var length (get, null) : Float; inline function get_length() return events[events.length - 1].time;
    /**
     * Is the animation looping on itslef
     */
    public var loop (default, null) : Bool;

    public function new(name : String, sm : StateMachine, animator : Animator, loop : Bool = true) 
    {
        super(name, sm);

        this.animator = animator;
        
        events = [];

        //Put -0.0001 to be able to handle the first event at 0
        currentTime = -0.0001;
        oldTime = -0.0001;

        this.loop = loop; 

        init();
    }

    //-------------------------------
    //#region Private API
    //-------------------------------
    override function onStateEnter(info:StateChangeInfo) 
    {
        super.onStateEnter(info);

        currentTime = -0.0001;
    }

    override function onStateUpdate(dt:Float) 
    {
        super.onStateUpdate(dt);

        //Return if not looping and at the end
        if(!loop && currentTime > length)
            return;

        oldTime = currentTime;
        currentTime += dt;

        for (e in events)
        {
            if(e.time > oldTime && e.time < currentTime)
            {
                e.event();
            }        
        }

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
    /**
     * Adds a new key event
     * @param time time of the event
     * @param event function to call when the event is triggered
     */
    public function addEvent(time : Float, event : Void -> Void)
    {
        for (e in events)
        {
            if(e.time == time)
                throw 'Animation $name has already an event at $time -> $e';
        }

        events.push({time : time, event : event});

        //Sort events to have them in ascending order
        events.sort(function(a, b) 
        {
            if(a.time < b.time) return -1;
            else if(a.time > b.time) return 1;
            else return 0;
        });
    }
    //#endregion
}

typedef EventKey =
{
    time : Float,
    event : Void -> Void
};