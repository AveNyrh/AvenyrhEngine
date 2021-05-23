package examples.src;

import avenyrh.physic.PhysicGameObject;
import avenyrh.Color;
import h2d.Tile;
import echo.World;
import h2d.Object;

class StaticObject extends PhysicGameObject
{

    override public function new(name : String, parent : Object, world : World, colType : ColliderType) 
    {
        super(name, parent, world, colType);
        
        changeTile(Tile.fromColor(Color.iBROWN, 10, 10));

        body.mass = 0;
    }
}