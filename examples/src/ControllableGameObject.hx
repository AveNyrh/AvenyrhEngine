package examples.src;

import avenyrh.gameObject.SpriteComponent;
import avenyrh.gameObject.GameObject;

class ControllableGameObject extends GameObject
{
    public var movementSpeed : Float = 2.2;
    
    @range(2, 3)
    public var rotationSpeed : Float = 2.2;

    public var testInt : Int = 2;

    @range(0, 4)
    public var testIntRange : Int = 2;

    public override function init()
    {
        super.init();

        var sc = new SpriteComponent();
        sc.tile = hxd.Res.CarreRouge.toTile();
        addComponent(sc);

        setPosition(100, 100);
        scale(2);

        addComponent(new SimpleAnimator("Simple Animator"));

        var go : FixedGameObject = new FixedGameObject("Child of controlable go", this);
        go.setPosition(10, 10);

        var go2 : FixedGameObject = new FixedGameObject("Child of controlable go 2", this);
        go2.setPosition(-10, 10);

        // var rtti = haxe.rtti.Rtti.getRtti(Type.getClass(this));
        // trace(rtti);
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

enum TestEnum
{
    Value1;
    Value2;
    Value3;
}