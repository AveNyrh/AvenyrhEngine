package avenyrh.gameObject;

import avenyrh.imgui.ImGui;
import haxe.ds.StringMap;
import avenyrh.engine.SaveLoader;
import avenyrh.engine.Inspector;
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
        particles.name = 'Particle-${gameObject.name}';
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
        po.emitDistY = group.emitDistY;
        po.emitAngle = group.emitAngle;
        po.emitDelay = group.emitDelay;
        po.emitSync = group.emitSync;
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
        group.emitDistY = po.emitDistY;
        group.emitAngle = po.emitAngle;
        group.emitDelay = po.emitDelay;
        group.emitSync = po.emitSync;
        group.fadeIn = po.fadeIn;
        group.fadeOut = po.fadeOut;
        group.fadePower = po.fadePower;
        group.isRelative = po.isRelative;
    }

    override function drawInfo() 
    {
        super.drawInfo();

        if(Inspector.button("Save", uID))
            saveParticle();

        //maxNumber : Int
        var nb : Array<Int> = [group.nparts];
        if(Inspector.dragFields("Max Number", uID, nb))
            group.nparts = nb[0];

        //dx, dy : Int
        var pos : Array<Int> = [group.dx, group.dy];
        if(Inspector.dragFields("Part pos", uID, pos))
        {
            group.dx = pos[0];
            group.dy = pos[1];
        }
        
        //loop : Bool
        var l : Bool = Inspector.checkbox("Loop", uID, group.emitLoop);
        if(group.emitLoop != l)
        {
            group.emitLoop = l;
            loop = l;
            group.enable = true;
            group.rebuild();
        }

        //size : Float
        var s : Array<Float> = [group.size];
        if(Inspector.dragFields("Size", uID, s))
            group.size = s[0];

        //sizeRand : Float
        var sr : Array<Float> = [group.sizeRand];
        if(Inspector.dragFields("Size rand", uID, sr))
            group.sizeRand = sr[0];

        //sizeIncr : Float
        var si : Array<Float> = [group.sizeIncr];
        if(Inspector.dragFields("Size incr", uID, si))
            group.sizeIncr = si[0];

        //rotationInit : Float
        var ri : Array<Float> = [group.rotInit];
        if(Inspector.dragFields("Rot init", uID, ri))
            group.rotInit = ri[0];

        //rotationSpeed : Float
        var rs : Array<Float> = [group.rotSpeed];
        if(Inspector.dragFields("Rot speed", uID, rs))
            group.rotSpeed = rs[0];

        //rotationSpeedRand : Float
        var rsr : Array<Float> = [group.rotSpeedRand];
        if(Inspector.dragFields("Rot spd rnd", uID, rsr))
            group.rotSpeedRand = rsr[0];

        //rotationAuto : Bool
        var ra : Bool = Inspector.checkbox("Rot auto", uID, group.rotAuto);
        if(group.rotAuto != ra)
            group.rotAuto = ra;

		//gravity : Float
        var g : Array<Float> = [group.gravity];
        if(Inspector.dragFields("Gravity", uID, g))
            group.gravity = g[0];

        //gravity angle : Float
        var ga : Array<Float> = [group.gravityAngle];
        if(Inspector.dragFields("Gravity angle", uID, ga))
            group.gravityAngle = ga[0];

		//life : Float
        var li : Array<Float> = [group.life];
        if(Inspector.dragFields("Life", uID, li))
            group.life = li[0];

        //lifeRand : Float
        var lir : Array<Float> = [group.lifeRand];
        if(Inspector.dragFields("Life rand", uID, lir))
            group.lifeRand = lir[0];

		//speed : Float
        var sp : Array<Float> = [group.speed];
        if(Inspector.dragFields("Speed", uID, sp))
            group.speed = sp[0];

		//speedRand : Float
        var spr : Array<Float> = [group.speedRand];
        if(Inspector.dragFields("Speed rand", uID, spr))
            group.speedRand = spr[0];

        //speedIncr : Float
        var spi : Array<Float> = [group.speedIncr];
        if(Inspector.dragFields("Speed incr", uID, spi))
            group.speedIncr = spi[0];

	    //emitMode : PartEmitMode
        var i = Inspector.enumDropdown("EmitMode", uID, PartEmitMode, group.emitMode.getIndex());
        if(i != group.emitMode.getIndex())
            group.emitMode = haxe.EnumTools.createByIndex(PartEmitMode, i);

        //emitDist : Float
        var ed : Array<Float> = [group.emitDist];
        if(Inspector.dragFields("Emit dist", uID, ed))
            group.emitDist = ed[0];

        //emitDistY : Float
        var edy : Array<Float> = [group.emitDistY];
        if(Inspector.dragFields("Emit dist y", uID, edy))
            group.emitDistY = edy[0];

		//emitAngle : Float
        var ea : Array<Float> = [group.emitAngle];
        if(Inspector.dragFields("Emit angle", uID, ea))
            group.emitAngle = ea[0];

        //emitDelay : Float
        var ede : Array<Float> = [group.emitDelay];
        if(Inspector.dragFields("Emit delay", uID, ede))
            group.emitDelay = ede[0];

        //emitSync : Float
        var es : Array<Float> = [group.emitSync];
        if(Inspector.dragFields("Emit sync", uID, es))
            group.emitSync = es[0];

        //fadeIn : Float
        var fi : Array<Float> = [group.fadeIn];
        if(Inspector.dragFields("Fade in", uID, fi))
            group.fadeIn = fi[0];

		//fadeOut : Float
        var fo : Array<Float> = [group.fadeOut];
        if(Inspector.dragFields("Fade out", uID, fo))
            group.fadeOut = fo[0];

        //fadePower : Float
        var fp : Array<Float> = [group.fadePower];
        if(Inspector.dragFields("Fade power", uID, fp))
            group.fadePower = fp[0];

        //isRelative : Bool
        var ir : Bool = Inspector.checkbox("Is relative", uID, group.isRelative);
        if(ir != group.isRelative)
            group.isRelative = ir;
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
    public var emitDistY : Float;
    public var emitAngle : Float;
    public var emitDelay : Float;
    public var emitSync : Float;
    public var fadeIn : Float;
    public var fadeOut : Float;
    public var fadePower : Float;
    public var isRelative : Bool;

    public function new() { }
}