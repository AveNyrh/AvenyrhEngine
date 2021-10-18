import avenyrh.engine.SceneManager;
import avenyrh.AvenyrhApp;
import examples.src.*;


class Main extends AvenyrhApp
{
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

        SceneManager.addScene(new GameObjectScene());
        //SceneManager.addScene(new UIScene());
        //SceneManager.addScene(new PFScene());
        //SceneManager.addScene(new PhysicExampleScene());
    }
}