package avenyrh.examples;

import avenyrh.animation.Animation;

class SimpleAnimation extends Animation
{
    override function init() 
    {
        super.init();

        addEvent(0, () -> gameObject.changeTile(hxd.Res.CarreBlanc.toTile()));
        addEvent(1, () -> gameObject.changeTile(hxd.Res.CarreRouge.toTile()));
        addEvent(2, () -> gameObject.changeTile(hxd.Res.CarreBlanc.toTile()));
    }
}