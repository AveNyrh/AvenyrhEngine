package avenyrh.examples;

import avenyrh.gameObject.GameObject;

class FixedGameObject extends GameObject
{
    override function init() 
    {
        super.init();

        var t = hxd.Res.CarreBleu.toTile();
        changeTile(t);
        pivot = Pivot.CENTER;
        rotation = 0;
    }    
}