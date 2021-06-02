package examples.src;

import avenyrh.gameObject.SpriteComponent;
import avenyrh.gameObject.ParticleComponent;
import avenyrh.gameObject.GameObject;

class FixedGameObject extends GameObject
{
    var part : ParticleComponent;

    override function init() 
    {
        super.init();

        var t = hxd.Res.CarreBleu.toTile();
        addComponent(new SpriteComponent(t));

        part = cast addComponent(new ParticleComponent("TestParticle", hxd.Res.CarreBlanc.toTexture(), 1));
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
}