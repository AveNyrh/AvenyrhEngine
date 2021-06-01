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
        new SpriteComponent("Sprite of " + name, this, t);

        part = new ParticleComponent("TestParticle", this, hxd.Res.CarreBlanc.toTexture(), 1);
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