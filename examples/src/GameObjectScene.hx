package examples.src;

import echo.util.Debug;
import avenyrh.engine.SceneManager;
import avenyrh.InputManager;
import examples.src.pathfinding.PFScene;
import avenyrh.gameObject.GameObject;
import avenyrh.engine.Scene;

class GameObjectScene extends Scene
{
    var go : GameObject;
    var go2 : GameObject;

    override function added() 
    {
        super.added();

        spawnGameObject();
    }

    function spawnGameObject()
    {
        go = new ControllableGameObject("Controllable GameObject");
        
        go2 = new FixedGameObject("Fixed Game Object");
        go2.setPosition(200, 200);
        go2.scale(2);

        camera.target = go;
    }

    override function update(dt:Float) 
    {
        super.update(dt);

        if(hxd.Key.isPressed(hxd.Key.RIGHT))
        {
            SceneManager.addScene(new UIScene());
        }
        else if(hxd.Key.isPressed(hxd.Key.LEFT))
        {
            SceneManager.addScene(new PFScene());
        }
        else if(hxd.Key.isPressed(hxd.Key.SPACE))
        {
            camera.shake(2, 2, 10);
        }
    }
}