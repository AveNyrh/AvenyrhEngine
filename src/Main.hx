import avenyrh.scene.SceneSerializer;
import avenyrh.scene.SceneManager;
import avenyrh.AvenyrhApp;
import examples.src.*;
import examples.src.TestScene;


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
        sceneManagerData = new SceneManagerData();

        super.init();
        //SceneManager.addScene(new GameObjectScene());
        //SceneManager.addScene(new UIScene());
        //SceneManager.addScene(new PFScene());
        //SceneManager.addScene(new PhysicExampleScene());
    }
}