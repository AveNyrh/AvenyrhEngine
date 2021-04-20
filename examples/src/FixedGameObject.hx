package examples.src;

import avenyrh.gameObject.ParticleComponent;
import avenyrh.engine.Inspector;
import avenyrh.ui.Fold;
import avenyrh.gameObject.GameObject;

class FixedGameObject extends GameObject
{
    var part : ParticleComponent;

    override function init() 
    {
        super.init();

        var t = hxd.Res.CarreBleu.toTile();
        changeTile(t);
        pivot = Pivot.CENTER;
        rotation = 0;

        part = cast addComponent(new ParticleComponent(this, "TestParticle", hxd.Res.CarreBlanc.toTexture(), 1));
        part.loop = false;
    }

    override function update(dt:Float) 
    {
        super.update(dt);

        if(hxd.Key.isDown(hxd.Key.H))
            part.play();

        if(hxd.Key.isDown(hxd.Key.J))
            part.stop();
    }

    override function drawInfo(inspector : Inspector, fold : Fold) 
    {
        super.drawInfo(inspector, fold);
    }
}