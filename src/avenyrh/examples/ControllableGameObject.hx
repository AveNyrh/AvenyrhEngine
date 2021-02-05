package avenyrh.examples;

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

        var go = new FixedGameObject("Children Game Object", this);
        go.setPosition(10, 10);
        addChild(go);
    }

    public override function update(dt : Float) 
    {
        super.update(dt);
        //trace('${name} -> Update');

        if(InputManager.getKey("Right"))
            x += movementSpeed;
        if(InputManager.getKey("Left"))
            x -= movementSpeed;
        if(InputManager.getKey("Up"))
            y -= movementSpeed;
        if(InputManager.getKey("Down"))
            y += movementSpeed;

        if(InputManager.getKey("A"))
            rotation -= 0.01 * rotationSpeed;
        if(InputManager.getKey("E"))
            rotation += 0.01 * rotationSpeed;
    }
}