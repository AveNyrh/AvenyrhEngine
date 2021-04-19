package examples.src;

import avenyrh.engine.Inspector;
import avenyrh.ui.Fold;
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

    override function drawInfo(inspector:Inspector, fold:Fold) 
    {
        super.drawInfo(inspector, fold);

        inspector.button(fold, "TestButton", () -> x += 5);
    }
}