package examples.src;

import avenyrh.gameObject.ParticleComponent;
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

        addComponent(new ParticleComponent(this, "TestParticle", hxd.Res.CarreBlanc.toTexture(), 1));
    }    

    override function drawInfo(inspector : Inspector, fold : Fold) 
    {
        super.drawInfo(inspector, fold);
    }
}