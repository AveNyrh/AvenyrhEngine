package examples.src;

import avenyrh.InputManager;
import examples.src.pathfinding.PFScene;
import avenyrh.engine.Engine;
import avenyrh.gameObject.GameObject;
import avenyrh.engine.Scene;

class GameObjectScene extends Scene
{
    var go : GameObject;
    var go2 : GameObject;

    public override function new() 
    {
        super("Game Object Scene");
    }

    override function added() 
    {
        super.added();

        spawnGameObject();
    }

    function spawnGameObject()
    {
        go = new ControllableGameObject("Controllable GameObject", scroller);
        
        go2 = new FixedGameObject("Fixed Game Object", scroller);
        go2.setPosition(200, 200);
        go2.scale(2);
        go2.changeTile(hxd.Res.CarreVert.toTile());

        camera.target = go;
    }

    override function update(dt:Float) 
    {
        super.update(dt);

        return;

        if(hxd.Key.isPressed(hxd.Key.RIGHT))
        {
            Engine.instance.addScene(new UIScene());
        }
        else if(hxd.Key.isPressed(hxd.Key.LEFT))
        {
            Engine.instance.addScene(new PFScene());
        }
    }
}