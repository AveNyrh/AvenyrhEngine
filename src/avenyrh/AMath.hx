package avenyrh;

/**
 * Math used the most \
 * This is a complement of Math Haxe class
 */
class AMath 
{
    /**
	 * Math.PI
	 */
	inline public static var PI = 3.141592653589793;
	/**
	 * Default system epsilon
	 */
	inline public static var EPS = 1e-6;
	/**
	 * The square root of 2.
	 */
    inline public static var SQRT2 = 1.414213562373095;
	/**
	 * Multiply value by this constant to convert from radians to degrees
	 */
	inline public static var RAD_TO_DEG = 180 / PI;
	/**
	 * Multiply value by this constant to convert from degrees to radians
	 */
	inline public static var DEG_TO_RAD = PI / 180;
    
    /**
	 * Converts deg to radians
	 */
	inline public static function toRad(deg : Float) : Float
	{
		return deg * DEG_TO_RAD;
	}

	/**
	 * Converts rad to degrees
	 */
	inline public static function toDeg(rad : Float) : Float
	{
		return rad * RAD_TO_DEG;
    }
    
    //--------------------
    //#region Int
	//--------------------
    /**
	 * Returns min(x, y).
	 */
	inline public static function imin(x : Int, y : Int) : Int
	{
		return x < y ? x : y;
    }
    
    /**
	 * Returns max(x, y).
	 */
	inline public static function imax(x : Int, y : Int) : Int
	{
		return x > y ? x : y;
    }
    
    /**
	 * Returns the absolute value of x
	 */
	inline public static function iabs(x : Int) : Int
	{
		return x < 0 ? -x : x;
    }

    /**
	 * Returns the sign of x
	 */
    inline public static function isign(x : Int) : Int 
    {
		return (x > 0) ? 1 : (x < 0 ? -1 : 0);
    }

    /**
	 * Clamps x to the interval [min, max]
	 */
	inline public static function iclamp(x : Int, min : Int, max : Int) : Int
	{
		return (x < min) ? min : (x > max) ? max : x;
    }
	//#endregion

    //--------------------
    //#region Float
    //--------------------
    /**
	 * Returns min(x, y).
	 */
	inline public static function fmin(x : Float, y : Float) : Float
	{
		return x < y ? x : y;
    }
    
    /**
	 * Returns max(x, y).
	 */
	inline public static function fmax(x : Float, y : Float) : Float
	{
		return x > y ? x : y;
    }
    
    /**
	 * Returns the absolute value of x
	 */
	inline public static function fabs(x : Float) : Float
	{
		return x < 0 ? -x : x;
    }

    /**
	 * Clamps x to the interval [min, max]
	 */
	inline public static function fclamp(x : Float, min : Float, max : Float) : Float
	{
		return (x < min) ? min : (x > max) ? max : x;
    }

    /**
	 * Clamps x to the interval [0, 1]
	 */
	inline public static function fclamp01(x : Float) : Float
	{
		return (x < 0) ? 0 : (x > 1) ? 1 : x;
    }
    
    /**
	 * Returns the sign of x
	 */
    inline public static function fsign(x : Float) : Int 
    {
		return (x > 0) ? 1 : (x < 0 ? -1 : 0);
    }
	//#endregion

    /**
	 * Returns true if x is even
	 */
	inline public static function isEven(x : Int) : Bool
	{
		return (x & 1) == 0;
    }
    
    /**
	 * Linear interpolation from a to b with t = 0...1
	 */
	inline public static function lerp(a : Float, b : Float, t : Float) : Float
	{
		return a + (b - a) * t;
    }
    
    /**
	 * Rounds to closest int
	 */
	inline public static function round(x : Float) : Int
	{
		return Std.int(x > 0 ? x + .5 : x < 0 ? x - .5 : 0);
    }
    
    /**
	 * Returns the smallest integer greater than or equal to the given number
	 */
	inline public static function ceil(x : Float) : Int
	{
		if( x > .0)
		{
			var t = Std.int(x + .5);
			return (t < x) ? t + 1 : t;
		}
		else if( x < .0)
		{
			var t = Std.int(x - .5);
			return (t < x) ? t + 1 : t;
		}
		else
			return 0;
    }
    
    /**
	 * Returns the largest integer that is less than or equal to the given number
	 */
    inline public static function floor(x:Float) : Int 
    {
		if( x>=0 )
			return Std.int(x);
        else 
        {
			var i = Std.int(x);
			if( x==i )
				return i;
			else
				return i - 1;
		}
    }
    
    /**
	 * Returns true if x is in the interval [min, max]
	 */
	inline public static function inRange(x : Float, min : Float, max : Float) : Bool
	{
		return x >= min && x <= max;
    }
    
    /**
	 * Returns a pseudo random float in the interval [0, 1]
	 */
	inline public static function rand01() : Float
	{
		return Math.random();
    }

    /**
	 * Returns a pseudo random integer in the interval [0, max[
	 */
	inline public static function irand(?max : Float = 1) : Int
	{
		return Std.int(Math.random() * max);
    }

    /**
	 * Returns a pseudo random float in the interval [0, max]
	 */
	inline public static function frand(?max : Float = 1) : Float
	{
		return rand01() * max;
    }

    /**
	 * Returns a pseudo random integer in the interval [0, max]
	 */
	inline public static function irandRange(min : Int, max : Int) : Int
	{
        var mn = min - .4999;
		var mx = max + .4999;
		return round(mn + (mx - mn) * rand01());
    }

    /**
	 * Returns a pseudo random float in the interval [min, max]
	 */
	inline public static function frandRange(min : Float, max : Float) : Float
	{
		return min + (max - min) * frand();
    }

    /**
     * Distance between point a = [ax, ay] and b = [bx, by]
     */
    public static inline function dist(ax : Float, ay : Float, bx : Float, by : Float) : Float 
    {
		return Math.sqrt(fdistSqr(ax, ay, bx, by));
    }
    
    /**
     * Distance squarred in interger between point a = [ax, ay] and b = [bx, by]
     */
    public static inline function idistSqr(ax : Int, ay : Int, bx : Int, by : Int) : Int 
    {
		return (ax-bx) * (ax-bx) + (ay-by) * (ay-by);
	}

    /**
     * Distance squarred in float between point a = [ax, ay] and b = [bx, by]
     */
    public static inline function fdistSqr(ax : Float, ay : Float, bx : Float, by : Float) : Float 
    {
		return (ax-bx) * (ax-bx) + (ay-by) * (ay-by);
	}
}