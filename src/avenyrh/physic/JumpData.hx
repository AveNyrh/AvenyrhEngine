package avenyrh.physic;

class JumpData 
{
    public var height : Float;

    public var distance : Float;

    public function new(height : Float, distance : Float)
    {
        this.height = height;
        this.distance = distance;
    }

    public inline function InitialVelocity(Vx : Float) : Float
    {
        var v : Float = (2 * height * 100 * Vx) / (distance * 100 / 2);

        return v;
    }

    public inline function Gravity(Vx : Float) : Float
    {
        var g : Float = (2 * height * 100 * Vx * Vx) / ((distance * 100 / 2) * (distance * 100 / 2));

        return g;
    }
}