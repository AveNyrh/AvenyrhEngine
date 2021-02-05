package avenyrh.engine;

import avenyrh.utils.Tween;

class Tweeny extends Process
{
    static var tweens : Array<Tween>;

    override public function new(name : String, ?parent : Process) 
    {
        super(name, parent);

        tweens = [];
    }

    //--------------------
    //Public API
    //--------------------
    /**
     * Adds a tween to be updated
     */
    public static function register(t : Tween)
    {
        if(!tweens.contains(t))
            tweens.push(t);    
    }

    /**
     * Removes a tween
     */
    public static function unregister(t : Tween) 
    {
        if(tweens.contains(t))
            tweens.remove(t);    
    }

    //--------------------
    //Private API
    //--------------------
    override function update(dt:Float) 
    {
        super.update(dt);

        for (t in tweens)
            t.update(dt);
    }

    override function onDispose() 
    {
        super.onDispose();

        for(t in tweens)
            t.dispose();

        tweens = [];
    }
}