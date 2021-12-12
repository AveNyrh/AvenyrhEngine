package avenyrh.animation;

import avenyrh.utils.Tween;
import avenyrh.utils.Tween.TweenType;

class Track 
{
    /**
     * List of all events
     */
    var events : Array<TrackEvent> = [];

    /**
     * List of all tweens
     */
    var tweens : Array<TrackTween> = [];

    /**
     * Current time of the animation
     */
    public var currentTime (default, set) : Float;

    /**
     * Time at the last frame
     */
    var oldTime : Float;

    public function new()
    {
        //Put -0.0001 to be able to handle the first event at 0
        currentTime = -0.0001;
        oldTime = -0.0001;
    }

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
                throw 'Track has already an event at $time -> $e';
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

    public function removeEvent(time : Float)
    {
        var removed : Bool = false;

        for (e in events)
        {
            if(e.time == time)
            {
                events.remove(e);
                removed = true;
            }
        }

        if(!removed)
            throw 'Track has no event at $time';
    }

    public function addTween(tween : TweenType, start : Float, end : Float, upadate : Float -> Void)
    {
        tweens.push({tween : tween, startTime : start, endTime : end, update : upadate, wasUpdated : false});
    }

    public function removeTween(tween : TrackTween)
    {
        tweens.remove(tween);
    }
    //#endregion

    //-------------------------------
    //#region Private API
    //-------------------------------
    inline function isInBetween(value : Float, min : Float, max : Float) : Bool
    {
        return value > min && value < max;
    }
    //#endregion

    //-------------------------------
    //#region Getters & Setters
    //-------------------------------
    function set_currentTime(time : Float) : Float
    {
        currentTime = time;

        var i : Int = 0;

        //Events
        for (e in events)
        {
            //Check going forward
            if(e.time > oldTime && e.time <= currentTime)
            {
                e.event();
                break;
            }
            
            //Check going backward
            if(e.time <= oldTime && e.time > currentTime)
            {
                events[i - 1].event();
                break;
            }

            i++;
        }

        //Tweens
        for(t in tweens)
        {
            //Check if went out of a tween
            if(t.wasUpdated && !isInBetween(currentTime, t.startTime, t.endTime))
            {
                if(currentTime > t.endTime)
                {
                    //After
                    var inter : Float = Tween.interpolate(t.tween, t.endTime - t.startTime, t.endTime - t.startTime);
                    t.update(inter);
                }
                else 
                {
                    //Before
                    var inter : Float = Tween.interpolate(t.tween, 0, t.endTime - t.startTime);
                    t.update(inter);
                }

                t.wasUpdated = false;
            }

            if(isInBetween(currentTime, t.startTime, t.endTime))
            {
                var inter : Float = Tween.interpolate(t.tween, currentTime - t.startTime, t.endTime - t.startTime);
                t.update(inter);
                t.wasUpdated = true;
            }
        }

        return currentTime;
    }
    //#endregion
}

typedef TrackEvent =
{
    time : Float,
    event : Void -> Void
};

typedef TrackTween = 
{
    startTime : Float,
    endTime : Float,
    tween : TweenType,
    update : Float -> Void,
    wasUpdated : Bool
};