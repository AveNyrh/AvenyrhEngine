package avenyrh;

import avenyrh.engine.Inspector;
import avenyrh.utils.Timer;
import avenyrh.engine.Scene;
import avenyrh.gameObject.GameObject;
import avenyrh.engine.Process;

class Camera extends Process
{
    /**
     * X position of the camera
     */
    public var x (default, null) : Float;
    /**
     * Y position of the camera
     */
    public var y (default, null) : Float;
    /**
     * Zoom of the camera
     */
    public var zoom : Float = 1;
    /**
     * Target to follow \
     * Can be null to have a fixed camera
     */
    public var target (default, set) : Null<GameObject>;
    /**
     * Offset between the target and the camera
     */
    public var targetOffset : Vector2 = Vector2.ZERO;
    /**
     * Deadzone of the target tracking
     */
    public var deadzone : Float = 6;
    /**
     * Smoothing of the target tracking
     */
    public var smooth : Float = 1;
    /**
     * Snaping to the target, ignoring deadzone & smoothing
     */
    public var snap : Bool = false;

    public var shakePower : Float = 1;

    var dx : Float;

    var dy : Float;

    var scene : Scene;

    var bumpOffset : Vector2;

    var timer : Timer;

    override public function new(name : String, ?parent : Process, scene : Scene) 
    {
        super(name, parent);

        x = 0;
        y = 0;
        dx = 0;
        dy = 0;
        this.scene = scene;
        timer = new Timer(stopShake, 1, false, false);
        bumpOffset = Vector2.ZERO;
    }

    //--------------------
    //Public API
    //--------------------    
    public function bump(x : Float, y : Float) 
    {
        bumpOffset += Vector2.RIGHT *  x + Vector2.UP * y;
    }

    public function shake(time : Float, ?power : Float = 1) 
    {
        shakePower = power;
        timer.start(time);
    }

    public function stopShake() 
    {
        if(timer.play)
            timer.stop();
    }

    override function update(dt:Float) 
    {
        super.update(dt);

        //Follow target
        if(target != null)
        {
            //Target position
            var tx = target.x + targetOffset.x;
            var ty = target.y + targetOffset.y;

            if(!snap)
            {
                //Distance
                var d = AMath.dist(x, y, tx, ty);

                if(d >= deadzone)
                {
                    //Angle
                    var a = Math.atan2(ty - y, tx - x);

                    //Go toward target
                    dx = Math.cos(a) * (d - deadzone) * smooth * dt;
                    dy = Math.sin(a) * (d - deadzone) * smooth * dt;
                }
            }
            else 
            {
                dx = tx - x;
                dy = ty - y;
            }
        }

        x += dx;
        y += dy;
    }

    override function postUpdate(dt:Float) 
    {
        super.postUpdate(dt);

        var sx : Float = 0;
        var sy : Float = 0;

        sx = -x * zoom + width / 2;
        sy = -y * zoom + height / 2;

        //Bump friction
        bumpOffset.x *= Math.pow(0.75, dt);
        bumpOffset.y *= Math.pow(0.75, dt);

        //Bump
        sx += bumpOffset.x;
        sy += bumpOffset.y;

        //Shake
        if(timer.play)
        {
            sx += Math.cos(Process.time * 1.1) * 2.5 * shakePower * timer.ratio;
            sy += Math.sin(0.3 + Process.time * 1.7) * 2.5 * shakePower * timer.ratio;
        }

        //Scale
        // sx *= zoom;
        // sy *= zoom;

        //Round
        scene.scroller.x = AMath.round(sx);
        scene.scroller.y = AMath.round(sy);

        //Zoom
        scene.scroller.setScale(zoom);
    }

    override function onDispose() 
    {
        super.onDispose();

        timer.dispose();
    }

    override function drawInfo() 
    {
        super.drawInfo();

        // //Position
        // var pos : Array<Float> = [x, y];
        // Inspector.dragFloats("Position", uID, pos, 0.1);
        // x = pos[0];
        // y = pos[1];

        // //Zoom
        // var z : Array<Float> = [zoom];
        // Inspector.dragFloats("Zoom", uID, z, 0.1);
        // zoom = z[0];

        // //Target
        // Inspector.labelText("Target", uID, target == null ? "Null" : target.name);

        //Target offset
        var to : Array<Float> = [targetOffset.x, targetOffset.y];
        Inspector.dragFloats("Target offset", uID, to, 0.1);
        targetOffset.x = to[0];
        targetOffset.y = to[1];

        // //Deadzone
        // var dz : Array<Float> = [deadzone];
        // Inspector.dragFloats("Deadzone", uID, dz, 0.1);
        // deadzone = dz[0];

        // //Smooth
        // var s : Array<Float> = [smooth];
        // Inspector.dragFloats("Smooth", uID, s, 0.1);
        // smooth = s[0];

        // //Snap
        // snap = Inspector.checkbox("Snap", uID, snap);

        // //Shake power
        // var sp : Array<Float> = [shakePower];
        // Inspector.dragFloats("Shake power", uID, sp, 0.1);
        // shakePower = sp[0];
    }

    //--------------------
    //Getters & Setters
    //--------------------
    function set_target(go : GameObject) : GameObject
    {
        target = go;
        return target;
    }
}