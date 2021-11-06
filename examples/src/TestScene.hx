package examples.src;

import avenyrh.Color;
import avenyrh.gameObject.SpriteComponent;
import h2d.Tile;
import avenyrh.gameObject.GameObject;
import avenyrh.scene.Scene;
import examples.src.TestComponent;

class TestScene extends Scene
{
    public var testInt : Int = 4;

    public var testFloat : Float = 2.6;

    public var testBool : Bool = true;

    public var testString : String = "This is a test string";

    public var testIntArray : Array<Int> = [0, 1, 2, 3, 4, 5, 6];

    public var testEnum : TestSceneEnum = Value1;

    public var testGo : GameObject;

    public var testComp : TestComponent;

    var privateInt = -1;

    //public var testTile : Tile;

    override function added() 
    {
        super.added();

        //testTile = hxd.Res.CarreBleu.toTile();
        //trace(hxd.Res.CarreBleu.getInfo());

        testGo = new GameObject("SpriteGo", null);
        testGo.addComponent(new SpriteComponent(null, null, Tile.fromColor(Color.iWHITE, 25, 25)));
        // testComp = new TestComponent();
        // testGo.addComponent(testComp);
    }

    override function update(dt : Float) 
    {
        super.update(dt);
    }
}

enum TestSceneEnum
{
    Value1;
    Value2;
    Value3;
}