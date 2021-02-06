package examples.src;

import avenyrh.animation.Animation;

class SimpleAnimation2 extends Animation
{
    override function init() 
    {
        super.init();

        addEvent(0, () -> gameObject.changeTile(hxd.Res.CarreBleu.toTile()));
        addEvent(1, () -> gameObject.changeTile(hxd.Res.CarreVert.toTile()));
        addEvent(2, () -> gameObject.changeTile(hxd.Res.CarreBleu.toTile()));
    }
}