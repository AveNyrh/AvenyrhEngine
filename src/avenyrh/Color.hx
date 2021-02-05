package avenyrh;

import h3d.Vector;

class Color 
{
    public static inline function getA(c : Int) : Float return ((c>>24)&0xFF)/255;
	public static inline function getR(c : Int) : Float return ((c>>16)&0xFF)/255;
	public static inline function getG(c : Int) : Float return ((c>>8)&0xFF)/255;
	public static inline function getB(c : Int) : Float return (c&0xFF)/255;

	public static inline function intToRgba(c : Int) : Vector 
	{
		return new Vector(Std.int( getA(c) * 255), Std.int( getR(c) * 255), Std.int( getG(c) * 255), Std.int( getB(c) * 255));
	}

	public static inline function intToRgb(c : Int) : Col 
	{
		return {
			r : (c>>16)&0xFF,
			g : (c>>8)&0xFF,
			b : c&0xFF,
		}
	}
	
	public static inline function intToVector(c : Int) : h3d.Vector 
	{
		var c = intToRgb(c);
		return new h3d.Vector(c.r / 255, c.g / 255, c.b / 255);
	}
	
	public static inline function rgbaToInt(c : Col32) : Int 
	{
		return (c.a << 24) | (c.r<<16 ) | (c.g<<8) | c.b;
	}

    //--------------------
    //Colors
	//--------------------
	//Ints
    public static inline var iWHITE : Int = 0xFFFFFFFF;
	public static inline var iBLACK : Int = 0xFF000000;
    public static inline var iRED : Int = 0xFFFF0000;
	public static inline var iGREEN : Int = 0xFF00FF00;
	public static inline var iBLUE : Int = 0xFF0000FF;
	public static inline var iYELLOW : Int = 0xFFFFFF00;
	public static inline var iCYAN : Int = 0xFF00FFFF;
    public static inline var iPINK : Int = 0xFFFF9191;
	public static inline var iLIMEGREEN : Int = 0xFFAEF02A;
	public static inline var iGREY : Int = 0xFF646464;
	public static inline var iLIGHTGREY : Int = 0xFF969696;
	public static inline var iDARKGREY : Int = 0xFF424242;
	public static inline var iBROWN : Int = 0xFF8B4513;
	public static inline var iBEIGE : Int = 0xFFE6D59E;
	public static inline var iCARAMEL : Int = 0xFFFFEF21;
	public static inline var iDARKBLUE : Int = 0xFF0A1B2A;

	//Vector
	public static var WHITE (get, never) : Vector; static inline function get_WHITE() return intToVector(iWHITE);
	public static var BLACK (get, never) : Vector; static inline function get_BLACK() return intToVector(iBLACK);
	public static var RED (get, never) : Vector; static inline function get_RED() return intToVector(iRED);
	public static var GREEN (get, never) : Vector; static inline function get_GREEN() return intToVector(iGREEN);
	public static var BLUE (get, never) : Vector; static inline function get_BLUE() return intToVector(iBLUE);
	public static var YELLOW (get, never) : Vector; static inline function get_YELLOW() return intToVector(iYELLOW);
	public static var CYAN (get, never) : Vector; static inline function get_CYAN() return intToVector(iCYAN);
	public static var PINK (get, never) : Vector; static inline function get_PINK() return intToVector(iPINK);
	public static var LIMEGREEN (get, never) : Vector; static inline function get_LIMEGREEN() return intToVector(iLIMEGREEN);
	public static var GREY (get, never) : Vector; static inline function get_GREY() return intToVector(iGREY);
	public static var LIGHTGREY (get, never) : Vector; static inline function get_LIGHTGREY() return intToVector(iLIGHTGREY);
	public static var DARKGREY (get, never) : Vector; static inline function get_DARKGREY() return intToVector(iDARKGREY);
	public static var BROWN (get, never) : Vector; static inline function get_BROWN() return intToVector(iBROWN);
	public static var BEIGE (get, never) : Vector; static inline function get_BEIGE() return intToVector(iBEIGE);
	public static var CARAMEL (get, never) : Vector; static inline function get_CARAMEL() return intToVector(iCARAMEL);
	public static var DARKBLUE (get, never) : Vector; static inline function get_DARKBLUE() return intToVector(iDARKBLUE);
}

typedef Col = 
{
	r	: Int, // 0-255
	g	: Int, // 0-255
	b	: Int, // 0-255
}

typedef Col32 = {
	>Col,
	a	: Int, // 0-255
}