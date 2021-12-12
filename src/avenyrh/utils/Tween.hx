package avenyrh.utils;

import avenyrh.engine.Tweeny;

class Tween 
{
    /**
     * Type of ease
     */
    public var type : TweenType;

    /**
     * Is the tween playing ?
     */
    public var play : Bool;

    /**
     * Is the tween looping when it ends ?
     */
    public var loop : Bool;

    /**
     * Starting value
     */
    public var from : Float;

    /**
     * Ending value
     */
    public var to : Float;

    /**
     * Current value
     */
    public var value (default, null) : Float;

    /**
     * Current time
     */
    public var time (default, null) : Float;

    /**
     * Duration of the tween
     */
    public var maxTime : Float;

    /**
     * Round to int the value if true
     */
    public var round : Bool;

    /**
     * Start callback
     */
    public var onStart : Null<Void -> Void>;

    /**
     * Update callback
     */
    public var onUpdate : Null<Float -> Void>;

    /**
     * End callback
     */
    public var onEnd : Null<Void -> Void>;
    
    /**
     * Is the gameObject destroyed
     */
    public var destroyed (default, null) : Bool;

    public function new(from : Float, to : Float, ?maxTime : Float = 1, ?type : TweenType = Linear) 
    {
        this.type = type;
        this.from = from;
        this.to = to;
        this.maxTime = maxTime;

        value = 0;
        time = 0;
        play = false;
        round = false;
        destroyed = false;

        Tweeny.register(this);
    }

    //-------------------------------
    //#region Public API
    //-------------------------------
    /**
     * Starts the tween
     */
    public function start() : Tween
    {
        if(destroyed)
            return null;

        play = true;
        time = 0;
        value = from;

        return this;
    }

    /**
     * Ends the tween
     */
    public function end() : Tween
    {
        if(destroyed)
            return null;

        play = false;

        if(onEnd != null)
            onEnd();

        return this;
    }

    /**
     * Sets onStart callback
     */
    public function setOnStart(cb : Void -> Void) : Tween 
    {
        onStart = cb;

        return this;
    }

    /**
     * Sets onUpdate callback
     */
    public function setOnUpdate(cb : Float -> Void) : Tween 
    {
        onUpdate = cb;

        return this;
    }

    /**
     * Sets onEnd callback
     */
    public function setOnEnd(cb : Void -> Void) : Tween 
    {
        onEnd = cb;

        return this;
    }

    public inline function toString() : String
    {
        return '$type : $from -> $to at $time/$maxTime | value = $value';
    }

    public function dispose() 
    {
        play = false;
        destroyed = true;

        Tweeny.unregister(this);
    }
    //#endregion

    //-------------------------------
    //#region Private API
    //-------------------------------
    @:allow(avenyrh.engine.Tweeny)
    function update(dt : Float) 
    {
        if(!play || destroyed)
            return;

        //Start
        if(time == 0 && onStart != null)
            onStart();

        //Clamp time between 0 and maxTime
        time = AMath.fclamp(time + dt, 0, maxTime);

        value = from + (to - from) * interpolate(type, time, maxTime);
        if(round)
            value = AMath.round(value);

        //Update
        if(onUpdate != null)
            onUpdate(value);

        //If at the end
        if(time == maxTime)
        {
            //Loop
            if(loop)
                time = 0;
            else 
                play = false;

            //End
            if(onEnd != null)
                onEnd();
        }
    }
    //#endregion

    //-------------------------------
    //#region Private API
    //-------------------------------
    public static function interpolate(type : TweenType, time : Float, maxTime : Float) : Float
    {
        var t : Float = time / maxTime;

        switch type
        {
            case Linear : return t;
            case Ease : return bezier(t, 0, 0, 1, 1);
            case EaseIn : return bezier(t, 0, 0, 0.5, 1);
            case EaseOut : return bezier(t, 0, 0.5, 1, 1);
            case Burn : return bezier(t, 0, 1, 0, 1);
            case BurnIn : return bezier(t, 0, 1, 1, 1);
            case BurnOut : return bezier(t, 0, 0, 0, 1);
            case ZigZag : return bezier(t, 0, 2.5, -1.5, 1);
            case Loop : return bezier(t, 0, 1.33, 1.33, 0);
            case LoopEaseIn : return bezier(t, 0, 0, 2.25, 0);
            case LoopEaseOut : return bezier(t, 0, 2.25, 0, 0);
            case Jump : return bezier(t, 0, 2, 2.79, 1);
            case LittleJump : return bezier(t, 0, 0.7, 1.5, 1);
            case BackIn : return bezier(t, 0, -1, 1, 2);
            case BackInEaseOut : return bezier(t, 0, -1, 1, 1);           
            default : throw 'Tween type not found : $type';
        }    
    }

    /**
     * Bezier curve \
     * Try values here : \
     * https://docs.google.com/spreadsheets/d/1ACTsfkqyk4E5Y_nyJIFzQrdwwwlFPhPYhuReOxznFck/edit?usp=sharing
     */
    static inline function bezier(t : Float, p0 : Float, p1 : Float, p2 : Float, p3 : Float) : Float 
    {
		return Math.pow(1 - t, 3) * p0 + 3 * t * Math.pow(1 - t, 2) * p1 + 3 * Math.pow(t, 2) * (1 - t) * p2 + Math.pow(t, 3) * p3;
	}
    //#endregion
}

enum TweenType
{
    /**
     * Linear from start to end
     */
    Linear;
    /**
     * Slow start, slow end
     */
    Ease;
    /**
     * Slow start, linear end
     */
    EaseIn;
    /**
     * Linear start, slow end
     */
    EaseOut;
    /**
     * Fast start, slow middle, fast ending
     */
    Burn;
    /**
     * Fast start, slow ending \
     * Like a logarithm
     */
    BurnIn;
    /**
     * Slow start, fast ending \
     * Like a exponential
     */
    BurnOut;
    /**
     * Goes up, down then up
     */
    ZigZag;
    /**
     * Goes from start to end back to start
     */
    Loop;
    /**
     * Loop with a slow start
     */
    LoopEaseIn;
    /**
     * Loop with a slow end
     */
    LoopEaseOut;
    /**
     * Goes to 2x ending value to back down in the end
     */
    Jump;
    /**
     * Like jump but goes to ~1,16x
     */
    LittleJump;
    /**
     * Goes back first, linear ending
     */
    BackIn;
    /**
     * Goes back first, slow ending
     */
    BackInEaseOut;
} 