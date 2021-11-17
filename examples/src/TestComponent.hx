package examples.src;

import avenyrh.gameObject.GameObject;
import avenyrh.gameObject.Component;

class TestComponent extends Component
{
    public var testInt : Int = 4;

    public var testFloat : Float = 2.6;

    public var testBool : Bool = true;

    public var testString : String = "This is a test string";

    public var testGo : GameObject = null;

    public var testComp : TestComponent = null;
}