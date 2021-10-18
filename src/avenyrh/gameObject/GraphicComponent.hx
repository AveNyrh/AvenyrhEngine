package avenyrh.gameObject;

import h2d.Object;

abstract class GraphicComponent extends Component
{
    public var x (get, set) : Float;

    public var y (get, set) : Float; 

    public var rotation (get, set) : Float; 

    public var scaleX (get, set) : Float; 

    public var scaleY (get, set) : Float; 

    //-------------------------------
    //#region Public API
    //-------------------------------
    public function setPosition(x : Float, y : Float)
    {
        getObject().setPosition(x, y);
    }

    public function rotate(a : Float)
    {
        getObject().rotate(a);
    }

    public function scale(s : Float)
    {
        getObject().scale(s);
    }

    public function setScale(s : Float)
    {
        getObject().setScale(s);
    }
    //#endregion

    public abstract function getObject() : Object;

    //-------------------------------
    //#region Getters & Setters
    //-------------------------------
    public function get_x() : Float
    {
        return getObject().x;
    }

    public function set_x(x : Float) : Float
    {
        getObject().x = x;

        return getObject().x;
    }

    public function get_y() : Float
    {
        return getObject().y;
    }

    public function set_y(y : Float) : Float
    {
        getObject().y = y;

        return getObject().y;
    }

    public function get_rotation() : Float
    {
        return getObject().rotation;
    }

    public function set_rotation(a : Float) : Float
    {
        getObject().rotation = a;

        return getObject().rotation;
    }

    public function get_scaleX() : Float
    {
        return getObject().scaleX;
    }

    public function set_scaleX(s : Float) : Float
    {
        getObject().scaleX = s;

        return getObject().scaleX;
    }

    public function get_scaleY() : Float
    {
        return getObject().scaleY;
    }

    public function set_scaleY(s : Float) : Float
    {
        getObject().scaleY = s;

        return getObject().scaleY;
    }
    //#endregion
}