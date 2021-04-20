package avenyrh.gameObject;

import haxe.ds.StringMap;
import avenyrh.engine.SaveLoader;
import avenyrh.engine.Inspector;
import avenyrh.ui.Fold;
import h2d.Particles;

class ParticleComponent extends Component
{
    var particles : Particles;

    var group : ParticleGroup;

    public var loop (default, set) : Bool = true;

    override public function new(gameObject : GameObject, name : String, texture : h3d.mat.Texture, frameCount : Int = 1) 
    {
        super(gameObject, name);

        particles = new Particles(gameObject);
		group = new ParticleGroup(particles);
        particles.addGroup(group);

        group.texture = texture;
        group.frameCount = frameCount;
        
        loadParticle();
    }

    public function play()
    {
        group.enable = true;
        group.rebuild();
    }

    public function stop() 
    {
        group.enable = false;
    }

    public function saveParticle()
    {
        var data : StringMap<ParticleOptions> = new StringMap();

        var po : ParticleOptions = new ParticleOptions();

        po.maxNumber = group.nparts;
        po.dx = group.dx;
        po.dy = group.dy;
        po.loop = group.emitLoop;
        po.size = group.size;
        po.sizeRand = group.sizeRand;
        po.sizeIncr = group.sizeIncr;
        po.rotationInit = group.rotInit;
        po.rotationSpeed = group.rotSpeed;
        po.rotationSpeedRand = group.rotSpeedRand;
        po.rotationAuto = group.rotAuto;
        po.gravity = group.gravity;
        po.gravityAngle = group.gravityAngle;
        po.life = group.life;
        po.lifeRand = group.lifeRand;
        po.speed = group.speed;
        po.speedRand = group.speedRand;
        po.speedIncr = group.speedIncr;
        po.emitMode = group.emitMode;
        po.emitDist = group.emitDist;
        po.emitAngle = group.emitAngle;
        po.emitDelay = group.emitDelay;
        po.fadeIn = group.fadeIn;
        po.fadeOut = group.fadeOut;
        po.fadePower = group.fadePower;
        po.isRelative = group.isRelative;

        data.set(name, po);

        SaveLoader.saveData("particles", data);
    }

    public function loadParticle()
    {
        var data : StringMap<ParticleOptions> = new StringMap();
        data = SaveLoader.loadData("particles", data);

        if(!data.exists(name))
            return;

        var po : ParticleOptions = cast data.get(name);

        group.nparts = po.maxNumber;
        group.dx = po.dx;
        group.dy = po.dy;
        group.emitLoop = po.loop;
        group.size = po.size;
        group.sizeRand = po.sizeRand;
        group.sizeIncr = po.sizeIncr;
        group.rotInit = po.rotationInit;
        group.rotSpeed = po.rotationSpeed;
        group.rotSpeedRand = po.rotationSpeedRand;
        group.rotAuto = po.rotationAuto;
        group.gravity = po.gravity;
        group.gravityAngle = po.gravityAngle;
        group.life = po.life;
        group.lifeRand = po.lifeRand;
        group.speed = po.speed;
        group.speedRand = po.speedRand;
        group.speedIncr = po.speedIncr;
        group.emitMode = po.emitMode;
        group.emitDist = po.emitDist;
        group.emitAngle = po.emitAngle;
        group.emitDelay = po.emitDelay;
        group.fadeIn = po.fadeIn;
        group.fadeOut = po.fadeOut;
        group.fadePower = po.fadePower;
        group.isRelative = po.isRelative;
    }

    override function drawInfo(inspector : Inspector, fold : Fold) 
    {
        super.drawInfo(inspector, fold);

        inspector.button(fold, "Save", () -> saveParticle());

        //maxNumber : Int
        inspector.field(fold, "Max number", () -> '${group.nparts}', (v) -> group.nparts = Std.parseInt(v));
        //dx, dy : Int
        inspector.doubleField(fold, "Dx", () -> '${group.dx}', (v) -> group.dx = Std.parseInt(v), "Dy", () -> '${group.dy}', (v) -> group.dy = Std.parseInt(v));
        //loop : Bool
        inspector.boolField(fold, "Loop", () -> group.emitLoop, (v) -> {group.emitLoop = v; loop = v; group.enable = true; group.rebuild();});
        //size : Float
        inspector.field(fold, "Size", () -> '${group.size}', (v) -> group.size = Std.parseFloat(v));
        //sizeRand : Float
        inspector.field(fold, "Size rand", () -> '${group.sizeRand}', (v) -> group.sizeRand = Std.parseFloat(v));
        //sizeIncr : Float
        inspector.field(fold, "Size incr", () -> '${group.sizeIncr}', (v) -> group.sizeIncr = Std.parseFloat(v));
        //rotationInit : Float
        inspector.field(fold, "Rotation init", () -> '${group.rotInit}', (v) -> group.rotInit = Std.parseFloat(v));
        //rotationSpeed : Float
        inspector.field(fold, "Rot speed", () -> '${group.rotSpeed}', (v) -> group.rotSpeed = Std.parseFloat(v));
        //rotationSpeedRand : Float
        inspector.field(fold, "Rot spd rnd", () -> '${group.rotSpeedRand}', (v) -> group.rotSpeedRand = Std.parseFloat(v));
        //rotationAuto : Bool
        inspector.boolField(fold, "Rot auto", () -> group.rotAuto, (v) -> group.rotAuto = v);
		//gravity : Float
        inspector.field(fold, "Gravity", () -> '${group.gravity}', (v) -> group.gravity = Std.parseFloat(v));
        //gravity angle : Float
        inspector.field(fold, "Gravity angle", () -> '${group.gravityAngle}', (v) -> group.gravityAngle = Std.parseFloat(v));
		//life : Float
        inspector.field(fold, "Life", () -> '${group.life}', (v) -> group.life = Std.parseFloat(v));
        //lifeRand : Float
        inspector.field(fold, "Life rand", () -> '${group.lifeRand}', (v) -> group.lifeRand = Std.parseFloat(v));
		//speed : Float
        inspector.field(fold, "Speed", () -> '${group.speed}', (v) -> group.speed = Std.parseFloat(v));
		//speedRand : Float
        inspector.field(fold, "Speed rand", () -> '${group.speedRand}', (v) -> group.speedRand = Std.parseFloat(v));
        //speedIncr : Float
        inspector.field(fold, "Speed incr", () -> '${group.speedIncr}', (v) -> group.speedIncr = Std.parseFloat(v));
	    //emitMode : PartEmitMode
        inspector.enumField(fold, "Emit mode", () -> group.emitMode.getIndex(), (v) -> group.emitMode = haxe.EnumTools.createByIndex(PartEmitMode, v), PartEmitMode);
		//emitDist : Float
        inspector.field(fold, "Emit dist", () -> '${group.emitDist}', (v) -> group.emitDist = Std.parseFloat(v));
		//emitAngle : Float
        inspector.field(fold, "Emit angle", () -> '${group.emitAngle}', (v) -> group.emitAngle = Std.parseFloat(v));
        //emitDelay : Float
        inspector.field(fold, "Emit delay", () -> '${group.emitDelay}', (v) -> group.emitDelay = Std.parseFloat(v));
        //fadeIn : Float
        inspector.field(fold, "Fade in", () -> '${group.fadeIn}', (v) -> group.fadeIn = Std.parseFloat(v));
		//fadeOut : Float
        inspector.field(fold, "Fade out", () -> '${group.fadeOut}', (v) -> group.fadeOut = Std.parseFloat(v));
        //fadePower : Float
        inspector.field(fold, "Fade power", () -> '${group.fadePower}', (v) -> group.fadePower = Std.parseFloat(v));
        //isRelative : Bool
        inspector.boolField(fold, "Is relative", () -> group.isRelative, (v) -> group.isRelative = v);
    }

    function set_loop(v : Bool) : Bool
    {
        loop = v;

        if(loop)
            particles.onEnd = () -> return;
        else
            particles.onEnd = stop;

        return loop;
    }
}

class ParticleOptions 
{
    public var maxNumber : Int;
    public var dx : Int;
    public var dy : Int;
    public var loop : Bool;
    public var size : Float;
    public var sizeRand : Float;
    public var sizeIncr : Float;
    public var rotationInit : Float;
    public var rotationSpeed : Float;
    public var rotationSpeedRand : Float;
    public var rotationAuto : Bool;
    public var gravity : Float;
    public var gravityAngle : Float;
    public var life : Float;
    public var lifeRand : Float;
    public var speed : Float;
    public var speedRand : Float;
    public var speedIncr : Float;
    public var emitMode : PartEmitMode;
    public var emitDist : Float;
    public var emitAngle : Float;
    public var emitDelay : Float;
    public var fadeIn : Float;
    public var fadeOut : Float;
    public var fadePower : Float;
    public var isRelative : Bool;

    public function new() { }
}