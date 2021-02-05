//package avenyrh.engine;

import avenyrh.examples.*;
import avenyrh.engine.Engine;
import avenyrh.engine.Process;

class Boot extends hxd.App
{
    public static var instance (default, null) : Boot;
    public static var avenyrhEngine (default, null) : Engine;

    /**
     * Boot
     */
    static function main() 
    {
        new Boot();
    }

    /**
     * Initialize the engine
     */
    override function init() 
    {
        super.init();

        instance = this;

        avenyrhEngine = new Engine(s2d);

        avenyrhEngine.addScene(new GameObjectScene());
        //avenyrhEngine.addScene(new UIScene());
        //avenyrhEngine.addScene(new PFScene());
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
}