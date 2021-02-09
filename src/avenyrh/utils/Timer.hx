package avenyrh.utils;

import avenyrh.engine.Engine;
import avenyrh.engine.IGarbageCollectable;

class Timer implements IGarbageCollectable
{
    /**
     * Callback function called at the end of the timer
     */
    public var callback : Void -> Void;
    /**
     * Current time of the timer
     */
    public var currentTime : Float;
    /**
     * End time of the timer
     */
    public var maxTime : Float;
    /**
     * Quick way to current / max time
     */
    public var ratio (get, never) : Float;
    /**
     * Is the timer playing ?
     */
    public var play (default, null) : Bool;
    /**
     * Is the timer looping ?
     */
    public var loop : Bool;

    var destroyed : Bool = false;

    public function new(cb : Void -> Void, time : Float, loop : Bool, ?play : Bool = false) 
    {
        callback = cb;
        currentTime = 0;
        maxTime = time;
        this.loop = loop;
        this.play = play;
    }

    //-------------------------------
    //#region Public API
    //-------------------------------
    /**
     * Starts the timer
     */
    public function start(?time : Float, ?loop : Bool) 
    {
        currentTime = 0;

        if(time != null)
            maxTime = time;

        if(loop != null)
            this.loop = loop;

        play = true;
    }

    /**
     * Stops the timer
     */
    public function stop() 
    {
        play = false;    
    }

    public function update(dt : Float) 
    {
        if(!play || !destroyed)
            return;

        currentTime += dt;

        if(currentTime >= maxTime)
        {
            callback();

            if(loop)
                currentTime = 0;
            else 
                play = false;
        }
    }

    public function toString() : String 
    {
        return "Timer : " + currentTime + "/" + maxTime;    
    }

    public function dispose() 
    {
        play = false;
        Engine.instance.gc.push(this);
    }

    /**
     * GarbageCollectable implementation
     */
    public function onDispose()
    {
        destroyed = true;
    }
    //#endregion

    //-------------------------------
    //#region Getters & Setters
    //-------------------------------
    inline function get_ratio() : Float
    {
        return currentTime / maxTime;    
    }
    //#endregion
}