package examples.src;

import avenyrh.animation.Animation;

class SimpleAnimation extends Animation
{
    override function init() 
    {
        super.init();
        
        addEvent(0, () -> sprite.sprite.tile = hxd.Res.CarreBlanc.toTile());
        addEvent(1, () -> sprite.sprite.tile = hxd.Res.CarreRouge.toTile());
        addEvent(2, () -> sprite.sprite.tile = hxd.Res.CarreBlanc.toTile());
    }
}