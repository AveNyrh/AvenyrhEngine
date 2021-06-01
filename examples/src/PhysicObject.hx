package examples.src;

import avenyrh.gameObject.GameObject;
import avenyrh.physic.PhysicGameObject;
import avenyrh.Color;
import h2d.Tile;
import echo.World;
import h2d.Object;

class PhysicObject extends PhysicGameObject
{
    override public function new(name : String, parent : GameObject, world : World, colType : ColliderType) 
    {
        super(name, parent, world, colType);

        //changeTile(Tile.fromColor(Color.iBLUE, 10, 10));
    }
}