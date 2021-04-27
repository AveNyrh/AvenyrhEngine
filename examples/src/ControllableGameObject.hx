package examples.src;

import avenyrh.InputManager;
import avenyrh.gameObject.GameObject;

class ControllableGameObject extends GameObject
{
    public var movementSpeed : Float = 2;
    public var rotationSpeed : Float = 2;

    public override function init()
    {
        super.init();

        var t = hxd.Res.CarreBleu.toTile();
        changeTile(t);
        pivot = Pivot.CENTER;

        setPosition(100, 100);
        rotation = 0;
        scale(2);

        addComponent(new SimpleAnimator(this, "Simple Animator"));

        var go = new FixedGameObject("Child of controlable go", this);
        go.setPosition(10, 10);
        addChild(go);

        var go2 : FixedGameObject = new FixedGameObject("Child of controlable go 2", this);
        go2.setPosition(-10, 10);
        addChild(go2);
    }

    public override function update(dt : Float) 
    {
        super.update(dt);

        if(hxd.Key.isDown(hxd.Key.D))
            x += movementSpeed;
        if(hxd.Key.isDown(hxd.Key.Q))
            x -= movementSpeed;
        if(hxd.Key.isDown(hxd.Key.Z))
            y -= movementSpeed;
        if(hxd.Key.isDown(hxd.Key.S))
            y += movementSpeed;

        if(hxd.Key.isDown(hxd.Key.A))
            rotation -= 0.01 * rotationSpeed;
        if(hxd.Key.isDown(hxd.Key.E))
            rotation += 0.01 * rotationSpeed;
    }
}