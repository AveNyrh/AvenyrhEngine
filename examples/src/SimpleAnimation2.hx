package examples.src;

import avenyrh.animation.Animation;

class SimpleAnimation2 extends Animation
{
    override function init() 
    {
        super.init();

        addEvent(0, () -> sprite.sprite.tile = hxd.Res.CarreBleu.toTile());
        addEvent(1, () -> sprite.sprite.tile = hxd.Res.CarreVert.toTile());
        addEvent(2, () -> sprite.sprite.tile = hxd.Res.CarreBleu.toTile());
    }
}