package avenyrh.examples;

import avenyrh.examples.pathfinding.PFScene;
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
        go = new ControllableGameObject("Controllable GameObject");

        go2 = new FixedGameObject("Fixed Game Object");
        go2.setPosition(200, 200);
        go2.scale(2);
        go2.changeTile(hxd.Res.CarreVert.toTile());

        camera.target = go;
    }

    override function update(dt:Float) 
    {
        super.update(dt);

        if(InputManager.getKeyDown("RightArrow"))
        {
            Engine.instance.addScene(new UIScene());
        }
        else if(InputManager.getKeyDown("LeftArrow"))
        {
            Engine.instance.addScene(new PFScene());
        }
    }
}