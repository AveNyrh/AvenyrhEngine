package avenyrh;

import avenyrh.engine.Engine;
import avenyrh.engine.Process;

class AvenyrhApp extends hxd.App
{
    public static var instance (default, null) : AvenyrhApp;
    
    public static var avenyrhEngine (default, null) : Engine;

    /**
     * Initialize the engine
     */
    override function init() 
    {
        super.init();

        instance = this;

        avenyrhEngine = new Engine(s2d, engine);
    }

    /**
     * Update the engine
     * @param dt deltaTime
     */
    override function update(dt : Float) 
    {
        super.update(dt);
        Process.updateAll(dt);
    }

    override function onResize() 
    {
        super.onResize();

        Process.resizeAll();
    }
}