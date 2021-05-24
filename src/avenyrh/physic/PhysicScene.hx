package avenyrh.physic;

import avenyrh.engine.Inspector;
import echo.util.Debug.HeapsDebug;
import echo.World;
import avenyrh.engine.Scene;

class PhysicScene extends Scene
{
    var world : World;

    var debug : HeapsDebug;

    var simulate : Bool = true;

    var drawDebug : Bool = true;

    override function added() 
    {
        super.added();

        world = new World
        (
            {
                width : width,
                height : height,
                x : width / 2,
                y : height / 2,
                gravity_y : 100,
                iterations : 5,
            }
        );

        debug = new HeapsDebug(scroller);
        scroller.addChildAt(debug.canvas, 100);
    }

    override function update(dt : Float) 
    {
        super.update(dt);

        if(simulate)
            world.step(dt);

        if(drawDebug)
            debug.draw(world);
    }

    override function drawInfo() 
    {
        super.drawInfo();

        var s : Bool = Inspector.checkbox("Simulate", uID, simulate);
        simulate = s;
    }
}