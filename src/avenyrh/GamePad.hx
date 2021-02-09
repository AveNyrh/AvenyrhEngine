package avenyrh;

import hxd.Math;
import hxd.Pad;

@:allow(avenyrh.engine.Engine, avenyrh.InputManager)
class GamePad 
{
    static var ALL : Array<GamePad> = [];

    var pad : Null<Pad>;
    
    var lastValues : Array<Float>;

    static var mapping : Array<Int> = 
    [
        Pad.DEFAULT_CONFIG.A,
		Pad.DEFAULT_CONFIG.B,
		Pad.DEFAULT_CONFIG.X,
		Pad.DEFAULT_CONFIG.Y,
		Pad.DEFAULT_CONFIG.back,
		Pad.DEFAULT_CONFIG.start,
		Pad.DEFAULT_CONFIG.LT,
		Pad.DEFAULT_CONFIG.RT,
		Pad.DEFAULT_CONFIG.LB,
		Pad.DEFAULT_CONFIG.RB,
		Pad.DEFAULT_CONFIG.analogClick,
		Pad.DEFAULT_CONFIG.ranalogClick,
		Pad.DEFAULT_CONFIG.dpadUp,
		Pad.DEFAULT_CONFIG.dpadDown,
		Pad.DEFAULT_CONFIG.dpadLeft,
        Pad.DEFAULT_CONFIG.dpadRight,
		Pad.DEFAULT_CONFIG.analogX,
		Pad.DEFAULT_CONFIG.analogY,
		Pad.DEFAULT_CONFIG.ranalogX,
		Pad.DEFAULT_CONFIG.ranalogY
    ];

    public var deadZone : Float;

    public var axisAsButtonDeadZone : Float;

    public function new(?deadZone : Float)
    {
        ALL.push(this);

        lastValues = [];
        for(k in [GamePadKey.LT, GamePadKey.RT])
            lastValues.push(0);

        if(deadZone != null)
            this.deadZone = deadZone;
        else 
            this.deadZone = 0.2;

        axisAsButtonDeadZone = 0.7;
    }

    //-------------------------------
    //#region Public API
    //-------------------------------
    /**
     * Makes the gamePad rumble
     * @param strength Strength of the rumble
     * @param time Time of the rumble
     */
    public function rumble(strength : Float, time : Float) 
    {
        if(!hasPad())
            return;

		pad.rumble(strength, time);
	}

    public function getPadAxisValue(key : GamePadKey) : Float
    {
        if(!hasPad())
            return 0;

        var value : Float = key.getIndex() > -1 && key.getIndex() < pad.values.length ? pad.values[mapping[key.getIndex()]] : 0;
        value = Math.abs(value) < deadZone ? 0 : value;
        return value;
    }

    /**
     * Checks if the specified key is up this frame
     * @param key Key to check
     */
    public function getKeyUp(key : GamePadKey) : Bool 
    {
        if(!hasPad())
            return false;

        switch(key)
        {
            case LT :
                var value = getPadAxisValue(key);
                return value > axisAsButtonDeadZone && lastValues[0] < 0;
            case RT :
                var value = getPadAxisValue(key);
                return value > axisAsButtonDeadZone && lastValues[1] < 0;
            default :
                return pad.isReleased(mapping[key.getIndex()]);
        }
    }

    /**
     * Checks if the specified key is down this frame
     * @param key Key to check
     */
    public function getKeyDown(key : GamePadKey) : Bool 
    {
        if(!hasPad())
            return false;
        
        switch(key)
        {
            case LT :
                var value = getPadAxisValue(key);
                return value < axisAsButtonDeadZone && lastValues[0] > 0;
            case RT :
                var value = getPadAxisValue(key);
                return value < axisAsButtonDeadZone && lastValues[1] > 0;
            default :
                return pad.isPressed(mapping[key.getIndex()]);
        }
    }

    /**
     * Gets the key current value
     * @param key Key to check
     */
    public inline function getKey(key : GamePadKey) : Bool
    {
        return false;
    }
    //#endregion

    //-------------------------------
    //#region Private API
    //-------------------------------
    private inline function hasPad() : Bool 
    {
        if(pad == null)
            pad = InputManager.getPad(getIndex(this));

        return pad != null;    
    }

    private static function getIndex(gamePad : GamePad) : Int
    {
        var i : Int = 0;
        for(gp in ALL)
        {
            if(gp == gamePad)
                return i;

            i++;
        }

        return -1;
    }

    private static function lateUpdateAll() 
    {
        for(gp in ALL)
            gp.lateUpdate();
    }

    private function lateUpdate() 
    {
        if(!hasPad())
            return;
        
        lastValues[0] = pad.values[mapping[GamePadKey.LT.getIndex()]];
        lastValues[1] = pad.values[mapping[GamePadKey.RT.getIndex()]];
    }
    //#endregion
}

enum abstract GamePadKey(Int)
{
    var A = 0;
	var B = 1;
	var X = 2;
	var Y = 3;
	var SELECT = 4;
	var START = 5;
	var LT = 6;
	var RT = 7;
	var LB = 8;
	var RB = 9;
	var LSTICK = 10;
	var RSTICK = 11;
	var DPAD_UP = 12;
	var DPAD_DOWN = 13;
	var DPAD_LEFT = 14;
	var DPAD_RIGHT = 15;
	var AXIS_LEFT_X = 16;
	var AXIS_LEFT_Y	= 17;//19
	var AXIS_RIGHT_X = 18;//22
	var AXIS_RIGHT_Y = 19;//25

    public inline function getIndex() : Int
    {
        return this;
    }

    public inline static var length : Int = 20;
}