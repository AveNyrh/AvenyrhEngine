import examples.src.*;
import examples.src.pathfinding.PFScene;
import avenyrh.engine.Engine;
import avenyrh.engine.Process;

class Main extends hxd.App
{
    public static var instance (default, null) : Main;
    public static var avenyrhEngine (default, null) : Engine;

    /**
     * Main
     */
    static function main() 
    {
        new Main();
    }

    /**
     * Initialize the engine
     */
    override function init() 
    {
        super.init();

        instance = this;

        avenyrhEngine = new Engine(s2d, engine);

        //avenyrhEngine.addScene(new GameObjectScene());
        //avenyrhEngine.addScene(new UIScene());
        //avenyrhEngine.addScene(new PFScene());
        avenyrhEngine.addScene(new PhysicExampleScene());
    }

    /**
     * Update the engine
     * @param dt deltaTime
     */
    override function update(dt : Float) 
    {
        super.update(dt);
        @:privateAccess Process.updateAll(dt);
    }

    override function onResize() 
    {
        super.onResize();

        Process.resizeAll();
    }
}