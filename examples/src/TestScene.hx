package examples.src;

import avenyrh.gameObject.GameObject;
import avenyrh.engine.Scene;
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

    override function added() 
    {
        super.added();

        // testGo = new GameObject("TestGo", null);
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