package examples.src;

import avenyrh.physic.PhysicScene;

class PhysicExampleScene extends PhysicScene
{
    var po : PhysicObject;
    var po2 : PhysicObject;
    var so : StaticObject;

    override public function new() 
    {
        super("PhysicScene");
    }

    override function added() 
    {
        super.added();

        po = new PhysicObject("po", scroller, world, Capsule);

        po2 = new PhysicObject("po2", scroller, world, Capsule);
        po2.setPosition(100, 0);

        so = new StaticObject("so", scroller, world, Rect);
        so.setPosition(0, 200);
        so.scaleX = 4;
        so.scaleX = 50;

        world.listen(po.body, so.body);
        world.listen(po2.body, so.body, { separate : false });
    }

    override function update(dt : Float) 
    {
        super.update(dt);

        if(simulate)
        {
            if(po2.y > 300)
            {
                po2.setPosition(100, 0);
                po2.body.velocity = new hxmath.math.Vector2(0, 0);
            }
        }
    }
}