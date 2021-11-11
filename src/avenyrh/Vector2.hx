package avenyrh;

import avenyrh.imgui.ImGui;

private typedef Vector2Impl = {x : Float, y : Float}

@:forward abstract Vector2 (Vector2Impl) from Vector2Impl to Vector2Impl
{
    public var magnitude (get, never) : Float;

    private var self (get, never) : Vector2;

    public inline function new(x : Float, y : Float)
    {
        this = {x : x, y : y};
    }

    //-------------------------------
    //#region Public API
    //-------------------------------
    public inline function set(x : Float, y : Float) : Vector2
    {
        this.x = x;
        this.y = y;
        return this;
    }

    public inline function round() : Vector2 
    {
		this.x = Math.fround(this.x);
		this.y = Math.fround(this.y);
		return this;
    }
    
    public inline function floor() : Vector2 
    {
		this.x = Math.ffloor(this.x);
		this.y = Math.ffloor(this.y);
		return this;
	}

    public inline function ceil() : Vector2 
    {
		this.x = Math.fceil(this.x);
		this.y = Math.fceil(this.y);
		return this;
	}

    public inline function abs() : Vector2 
    {
		this.x = Math.abs(this.x);
		this.y = Math.abs(this.y);
		return this;
    }

    public function clone() : Vector2
    {
        return new Vector2(this.x, this.y);
    }

    public function distanceTo(other : Vector2) : Float
    {
        return (other - self).magnitude;
    }

    public function normalize() : Vector2
    {
        if(magnitude != 0)
            return self / magnitude;
        else 
            return Vector2.ZERO;
    }

    public inline function dot(other : Vector2) : Float 
    {
        var v : Vector2 = self * other;
        return v.x = v.y;
    }
    //#endregion
    
    //-------------------------------
    //#region Getters & Setters
    //-------------------------------
    private inline function get_self() : Vector2 
    {
		return (this : Vector2);
	}

    private inline function get_magnitude() : Float 
    {
        return Math.sqrt(this.x * this.x + this.y * this.y);
    }
    //#endregion

    //-------------------------------
    //#region Operators
    //-------------------------------
    @:commutative @:op(A += B)
    public inline function addAssign(other : Vector2) : Vector2 
    {
        this.x += other.x;
        this.y += other.y;
        return this;
    }

    @:commutative @:op(A -= B)
    public inline function substractAssign(other : Vector2) : Vector2 
    {
        this.x -= other.x;
        this.y -= other.y;
        return this;
    }

    @:commutative @:op(A *= B)
    public inline function multiplyAssign(other : Vector2) : Vector2 
    {
        this.x *= other.x;
        this.y *= other.y;
        return this;
    }

    @:commutative @:op(A /= B)
    public inline function divideAssign(other : Vector2) : Vector2 
    {
        this.x /= other.x;
        this.y /= other.y;
        return this;
    }

    @:commutative @:op(A + B)
    public inline function add(other : Vector2) : Vector2 
    {
        return clone().addAssign(other);
    }

    @:commutative @:op(A - B)
    public inline function substract(other : Vector2) : Vector2 
    {
        return clone().substractAssign(other);
    }

    @:commutative @:op(A * B)
    public inline function multiply(other : Vector2) : Vector2 
    {
        return clone().multiplyAssign(other);
    }

    @:commutative @:op(A / B)
    public inline function divide(other : Vector2) : Vector2 
    {
        return clone().divideAssign(other);
    }

    @:op(A += B)
    public function addFloatAssign(value : Float) : Vector2 
    {
        this.x += value;
        this.y += value;
        return this;    
    }

    @:op(A -= B)
    public function substractFloatAssign(value : Float) : Vector2 
    {
        this.x -= value;
        this.y -= value;
        return this;    
    }

    @:op(A *= B)
    public function multiplyFloatAssign(value : Float) : Vector2 
    {
        this.x *= value;
        this.y *= value;
        return this;    
    }

    @:op(A /= B)
    public function divideFloatAssign(value : Float) : Vector2 
    {
        this.x /= value;
        this.y /= value;
        return this;    
    }

    @:commutative @:op(A + B)
    public inline function addFloat(value : Float) : Vector2 
    {
        return clone().addFloatAssign(value);
    }

    @:commutative @:op(A - B)
    public inline function substractFloat(value : Float) : Vector2 
    {
        return clone().substractFloatAssign(value);
    }

    @:commutative @:op(A * B)
    public inline function multiplyFloat(value : Float) : Vector2 
    {
        return clone().multiplyFloatAssign(value);
    }

    @:commutative @:op(A / B)
    public inline function divideFloat(value : Float) : Vector2 
    {
        return clone().divideFloatAssign(value);
    }

    @:commutative @:op(A == B)
    public inline function equals(other : Vector2) : Bool 
    {
        return this.x == other.x && this.y == other.y;
    }

    @:commutative @:op(A != B)
    public inline function notEquals(other : Vector2) : Bool 
    {
        return !(this == other);
    }

    @:op(!A)
    public inline function isNull() : Bool 
    {
        return this == null;
    }

    @:from
    public static inline function fromImVec2(other : ImVec2) : Vector2
    {
        return new Vector2(other.x, other.y);
    }

    @:to
    public inline function toImVec2() : ImVec2
    {
        return {x : self.x, y : self.y};
    }

    @:from
    public static inline function fromExtImVec2(other : ExtDynamic<ImVec2>) : Vector2
    {
        return fromImVec2(cast other);
    }

    @:to
    public inline function toExtImVec2() : ExtDynamic<ImVec2>
    {
        return toImVec2();
    }
    
    public inline function toString() : String 
    {
        return 'x : ${this.x}, y : ${this.y}';
    }
    //#endregion

    //-------------------------------
    //#region Static variables
    //-------------------------------
    /**
     * Easy way to get {0, 0}
     */
    public static var ZERO (get, never) : Vector2; 

    private inline static function get_ZERO() : Vector2 
    {
        return new Vector2(0, 0);
    }

    /**
     * Easy way to get {1, 1}
     */
    public static var ONE (get, never) : Vector2; 

    private inline static function get_ONE() : Vector2 
    {
        return new Vector2(1, 1);
    }

    /**
     * Easy way to get {0, 1}
     */
    public static var UP (get, never) : Vector2; 

    private inline static function get_UP() : Vector2 
    {
        return new Vector2(0, 1);
    }

    /**
     * Easy way to get {0, -1}
     */
    public static var DOWN (get, never) : Vector2; 

    private inline static function get_DOWN() : Vector2 
    {
        return new Vector2(0, -1);
    }

    /**
     * Easy way to get {1, 0}
     */
    public static var RIGHT (get, never) : Vector2; 

    private inline static function get_RIGHT() : Vector2 
    {
        return new Vector2(1, 0);
    }

    /**
     * Easy way to get {-1, 0}
     */
    public static var LEFT (get, never) : Vector2; 

    private inline static function get_LEFT() : Vector2 
    {
        return new Vector2(-1, 0);
    }
    //#endregion
}