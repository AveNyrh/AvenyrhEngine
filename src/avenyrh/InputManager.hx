package avenyrh;

import avenyrh.GamePad.GamePadKey;
import haxe.ds.IntMap;
import hxd.Pad;
import hxd.Key;
import haxe.ds.StringMap;

@:allow(avenyrh.engine.Engine, avenyrh.GamePad)
class InputManager
{
    private static var keyMap : StringMap<KeyBinding>;
    private static var axisMap : StringMap<AxisBinding>;
    private static var pads : IntMap<Null<Pad>>;

    private static var initialized : Bool = false;

    /**
     * Called by the Engine
     */
    private static function init() 
    {
        if(initialized)
            return;

        keyMap = new StringMap<KeyBinding>();
        axisMap = new StringMap<AxisBinding>();
        pads = new IntMap<Null<Pad>>();

        initialized = true;
    }

    //--------------------
    //Public API
    //--------------------
    /**
     * Adds a custom keyboard key to the list
     * @param name Name of the custom key
     * @param key The key associated
     * @param keys Keys associated
     */
    public static function addKeyboardKey(name : String, ?key : Int, ?keys : Array<Int>)
    {
        if(!keyMap.exists(name))
            keyMap.set(name, new KeyBinding());

        if(key != null)
            keyMap.get(name).addKeyboardBindings([key]);
        else
            keyMap.get(name).addKeyboardBindings(keys);
    }

    /**
     * Adds a custom gamePad key to the list
     * @param name Name of the custom key
     * @param key The key associated
     * @param keys Keys associated
     */
    public static function addGamePadKey(name : String, gamePad : GamePad, ?key : GamePadKey, ?keys : Array<GamePadKey>)
    {
        if(!keyMap.exists(name))
            keyMap.set(name, new KeyBinding(gamePad));

        if(key != null)
            keyMap.get(name).addGamePadBindings(gamePad, [key]);
        else
            keyMap.get(name).addGamePadBindings(gamePad, keys);
    }

    /**
     * Adds a custom keyboard axis to the list
     * @param name Name of the axis
     * @param posKey Positive key for the axis
     * @param negKey Negative key for the axis
     * @param posKeys Positive keys for the axis
     * @param negKeys Negative keys for the axis
     */
    public static function addKeyboardAxis(name : String, ?posKey : Int, ?negKey : Int, ?posKeys : Array<Int>, ?negKeys : Array<Int>)
    {
        if(!axisMap.exists(name))
            axisMap.set(name, new AxisBinding());

        var pos : Array<Int> = posKey != null ? [posKey] : posKeys;
        var neg : Array<Int> = negKey != null ? [negKey] : negKeys;

        axisMap.get(name).addKeyboardBindings(pos, neg);
    }

    /**
     * Adds a custom gamePad axis to the list
     * @param name Name of the axis
     * @param gamePad GamePad
     * @param posKey Positive key for the axis
     * @param negKey Negative key for the axis
     * @param posKeys Positive keys for the axis
     * @param negKeys Negative keys for the axis
     */
    public static function addGamePadAxis(name : String, gamePad : GamePad, ?posKey : GamePadKey, ?negKey : GamePadKey, ?posKeys : Array<GamePadKey>, ?negKeys : Array<GamePadKey>)
    {
        if(!axisMap.exists(name))
            axisMap.set(name, new AxisBinding(gamePad));

        var pos : Array<GamePadKey> = posKey != null ? [posKey] : posKeys;
        var neg : Array<GamePadKey> = negKey != null ? [negKey] : negKeys;

        axisMap.get(name).addGamePadBindings(gamePad, pos, neg);
    }

    /**
     * Adds a custom joystick axis to the list
     * @param name Name of the axis
     * @param gamePad GamePad
     * @param joystickKey Joystick key for the axis
     * @param joystickKeys Joystick keys for the axis
     */
    public static function addGamePadJoystickAxis(name : String, gamePad : GamePad, ?joystickKey : GamePadKey, ?joystickKeys : Array<GamePadKey>)
    {
        if(!axisMap.exists(name))
            axisMap.set(name, new AxisBinding(gamePad));

        var joyKeys : Array<GamePadKey> = joystickKey != null ? [joystickKey] : joystickKeys;

        axisMap.get(name).addJoystickBindings(gamePad, joyKeys);
    }

    /**
     * Removes a custom key from the list
     * @param name Name of the custom key to remove
     */
    public static function removeKey(name : String)
    {
        if(keyMap.exists(name))
            keyMap.remove(name);
        else
            throw '[InputManager] : Key list does not contain ${name} so it can not be removed';
    }
    
    /**
     * Removes a custom axis from the list
     * @param name 
     */
    public static function removeAxis(name : String)
    {
        if(axisMap.exists(name))
            axisMap.remove(name);
        else
            throw '[InputManager] : Axis list does not contain ${name} so it can not be removed';
    }

    /**
     * Checks if the specified custom key is up this frame
     * @param name Name of the custom key to check
     */
    public static function getKeyUp(name : String) : Bool
    {
        if(!keyMap.exists(name))
            throw '[InputManager] : Key list does not contain ${name}';

        //Keyboard
        var keys : Array<Int> = keyMap.get(name).keyboardBindings;
        for(key in keys)
        {
            if(Key.isReleased(key))
                return true;
        }

        //Gamepad
        var padKeys : Array<GamePadKey> = keyMap.get(name).padBindings;
        for(key in padKeys)
        {
            if(keyMap.get(name).gamePad.getKeyUp(key))
                return true;
        }

        return false;
    }

    /**
     * Checks if the specified custom key is down this frame
     * @param name Name of the custom key to check
     */
    public static function getKeyDown(name : String) : Bool
    {
        if(!keyMap.exists(name))
            throw '[InputManager] : Key list does not contain ${name}';
    
        //Keyboard
        var keys : Array<Int> = keyMap.get(name).keyboardBindings;
        for(key in keys)
        {
            if(Key.isPressed(key))
                return true;
        }

        //Gamepad
        var padKeys : Array<GamePadKey> = keyMap.get(name).padBindings;
        for(key in padKeys)
        {
            if(keyMap.get(name).gamePad.getKeyDown(key))
                return true;
        }
    
        return false;
    }

    /**
     * Returns true if the specified key is pressed, false else
     * @param name Name of the custom key to check
     */
    public static function getKey(name : String) : Bool
    {
        if(!keyMap.exists(name))
            throw '[InputManager] : Key list does not contain ${name}';
        
        //Keyboard
        var keys : Array<Int> = keyMap.get(name).keyboardBindings;
        for(key in keys)
        {
            if(Key.isDown(key))
                return true;
        }

        //Gamepad
        var padKeys : Array<GamePadKey> = keyMap.get(name).padBindings;
        for(key in padKeys)
        {
            if(keyMap.get(name).gamePad.getKey(key))
                return true;
        }
    
        return false;
    }

    /**
     * Gets the axis value between -1 and 1
     * @param name Name of the axis
     */
    public static function getAxis(name : String) : Float
    {
        if(!axisMap.exists(name))
            throw '[InputManager] : Axis list does not contain ${name}';

        return axisMap.get(name).getAxisValue();
    }

    /**
     * Returns the number of gamePad connected
     * @return Number of gamePad
     */
    public static function getNumberOfGamePad() : Int
    {
        var nb : Int = 0;
        var i : Int = 0;

        for(p in pads)
        {
            if(pads.get(i) != null)
                nb++;

            i++;
        }

        return nb;
    } 

    //--------------------
    //Private API
    //--------------------
    private static function getPad(index : Int) : Null<Pad>
    {
        if(!pads.exists(index))
        {
            Pad.wait(addPad);
            return null;
        }
        else
            return pads.get(index);
    }

    private static function addPad(pad : Pad)
    {
        //Check if one pad has been disconected and reconnect it to ther first slot available
        for(i in pads.keys())
        {
            if(pads.get(i) == null)
            {
                pads.set(i, pad);
                pad.onDisconnect = function() disconetPad(pad);
                return;
            }
        }

        //Else add a new one
        var i : Int = getNumberOfGamePad();
        pads.set(i, pad);
        
        pad.onDisconnect = function() disconetPad(pad);
    }

    private static function disconetPad(pad : Pad)
    {
        var i : Int = 0;
        for(p in pads)
        {
            if(p == pad)
            {
                pads.set(i, null);
                GamePad.ALL[i].pad = null;
            }

            i++;
        }
    }
}

class KeyBinding
{
    public var gamePad (default, default) : Null<GamePad>;
    public var keyboardBindings (default, null) : Array<Int>;
    public var padBindings (default, null) : Array<GamePadKey>;

    public function new(?gamePad : GamePad) 
    {
        this.gamePad = gamePad;
        keyboardBindings = [];
        padBindings = [];
    }

    public function addKeyboardBindings(bindings : Array<Int>)
    {
        for(b in bindings)
            this.keyboardBindings.push(b);
    }

    public function addGamePadBindings(gamePad : GamePad, bindings : Array<GamePadKey>)
    {
        this.gamePad = gamePad;
        for(b in bindings)
            this.padBindings.push(b);
    }
}

class AxisBinding
{
    public var gamePad (default, default) : Null<GamePad>;
    public var posKeyboardBindings (default, null) : Array<Int>;
    public var negKeyboardBindings (default, null) : Array<Int>;
    public var posPadBindings (default, null) : Array<GamePadKey>;
    public var negPadBindings (default, null) : Array<GamePadKey>;
    public var joystickBindings (default, null) : Array<GamePadKey>;

    public function new(?gamePad : GamePad) 
    {
        this.gamePad = gamePad;
        this.posKeyboardBindings = [];
        this.negKeyboardBindings = [];
        this.posPadBindings = [];
        this.negPadBindings = [];
        this.joystickBindings = [];
    }

    public function addKeyboardBindings(posBindings : Array<Int>, negBindings : Array<Int>)
    {
        for(b in posBindings)
            this.posKeyboardBindings.push(b);

        for(b in negBindings)
            this.negKeyboardBindings.push(b);
    }

    public function addGamePadBindings(gamePad : GamePad, posBindings : Array<GamePadKey>, negBindings : Array<GamePadKey>)
    {
        this.gamePad = gamePad;
        for(b in posBindings)
            this.posPadBindings.push(b);

        for(b in negBindings)
            this.negPadBindings.push(b);
    }

    public function addJoystickBindings(gamePad : GamePad, joystickBindings : Array<GamePadKey>)
    {
        this.gamePad = gamePad;
        for(b in joystickBindings)
            this.joystickBindings.push(b);
    }

    public function getAxisValue() : Float
    {
        var value : Float = 0;

        //Keyboard
        //Positive
        var keys : Array<Int> = posKeyboardBindings;
        for(key in keys)
        {
            if(Key.isDown(key))
                value++;
        }
        //Negative
        keys = negKeyboardBindings;
        for(key in keys)
        {
            if(Key.isDown(key))
                value--;
        }

        //Gamepad
        //Positive
        var padKeys : Array<GamePadKey> = posPadBindings;
        for(key in padKeys)
        {
            value += gamePad.getPadAxisValue(key);
        }
        //Negative
        padKeys = negPadBindings;
        for(key in padKeys)
        {
            value -= gamePad.getPadAxisValue(key);
        }
        //Joystick
        padKeys = joystickBindings;
        for(key in padKeys)
        {
            value += gamePad.getPadAxisValue(key);
        }

        if(value > 1)
            value = 1;
        else if(value < -1)
            value = -1;

        return value;
    }
}