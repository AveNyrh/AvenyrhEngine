package examples.src;

import avenyrh.gameObject.GameObject;
import avenyrh.engine.Scene;

class TestScene extends Scene
{
    public var testInt : Int = 4;

    public var testFloat : Float = 2.6;

    public var testBool : Bool = true;

    public var testString : String = "This is a test string";

    //public var testEnum : TestSceneEnum = Value1;

    //public var testGo : GameObject;

    public override function new() 
    {
        super("Test Scene");
    }

    override function added() 
    {
        super.added();

        //testGo = new GameObject("TestGo", null);
    }
}

enum TestSceneEnum
{
    Value1;
    Value2;
    Value3;
}