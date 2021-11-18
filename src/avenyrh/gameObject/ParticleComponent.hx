package avenyrh.gameObject;

import h2d.Object;
import haxe.Unserializer;
import haxe.ds.StringMap;
import avenyrh.engine.SaveLoader;
import avenyrh.editor.Inspector;
import h2d.Particles;

class ParticleComponent extends Component
{
    static var data : StringMap<ParticleOptions>;

    var particles : Particles;

    var group : ParticleGroup;

    @hideInInspector
    public var isPlaying (default, null) : Bool = true;

    @hideInInspector
    public var loop (default, set) : Bool = true;

    @hideInInspector
    public var layer (default, null) : Int;

    override public function new(name : String, ?parent : Object, texture : h3d.mat.Texture, frameCount : Int = 1, ?layer : Int = 0) 
    {
        super(name);

        this.layer = layer;

        particles = new Particles(parent);
		group = new ParticleGroup(particles);
        particles.addGroup(group);

        group.texture = texture;
        group.frameCount = frameCount;
        
        loadParticle();
    }

    //-------------------------------
    //#region Public API
    //-------------------------------
    /**
     * Start the particles
     */
    public function play()
    {
        group.enable = true;
        group.rebuild();
        isPlaying = true;
    }

    /**
     * Stops all the particles
     */
    public function stop() 
    {
        group.enable = false;
        isPlaying = false;
    }

    /**
     * Saves particles in the res/sav/particles.sav file
     */
    public function saveParticle()
    {
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
        saveData();
    }

    /**
     * Loads particles options
     */
    public function loadParticle()
    {
        if(!data.exists(name))
            return;

        var po : ParticleOptions = data.get(name);

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
    //#endregion

    //-------------------------------
    //#region Private API
    //-------------------------------
    override function drawInfo() 
    {
        super.drawInfo();

        if(Inspector.button("Save", uID))
            saveParticle();

        //maxNumber : Int
        var nb : Array<Int> = [group.nparts];
        if(Inspector.dragInts("Max Number", uID, nb))
            group.nparts = nb[0];

        //dx, dy : Int
        var pos : Array<Int> = [group.dx, group.dy];
        if(Inspector.dragInts("Part pos", uID, pos))
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
        if(Inspector.dragFloats("Size", uID, s, 0.1))
            group.size = s[0];

        //sizeRand : Float
        var sr : Array<Float> = [group.sizeRand];
        if(Inspector.dragFloats("Size rand", uID, sr, 0.1))
            group.sizeRand = sr[0];

        //sizeIncr : Float
        var si : Array<Float> = [group.sizeIncr];
        if(Inspector.dragFloats("Size incr", uID, si, 0.1))
            group.sizeIncr = si[0];

        //rotationInit : Float
        var ri : Array<Float> = [group.rotInit];
        if(Inspector.dragFloats("Rot init", uID, ri, 0.1))
            group.rotInit = ri[0];

        //rotationSpeed : Float
        var rs : Array<Float> = [group.rotSpeed];
        if(Inspector.dragFloats("Rot speed", uID, rs, 0.1))
            group.rotSpeed = rs[0];

        //rotationSpeedRand : Float
        var rsr : Array<Float> = [group.rotSpeedRand];
        if(Inspector.dragFloats("Rot spd rnd", uID, rsr, 0.1))
            group.rotSpeedRand = rsr[0];

        //rotationAuto : Bool
        var ra : Bool = Inspector.checkbox("Rot auto", uID, group.rotAuto);
        if(group.rotAuto != ra)
            group.rotAuto = ra;

		//gravity : Float
        var g : Array<Float> = [group.gravity];
        if(Inspector.dragFloats("Gravity", uID, g, 0.1))
            group.gravity = g[0];

        //gravity angle : Float
        var ga : Array<Float> = [group.gravityAngle];
        if(Inspector.dragFloats("Gravity angle", uID, ga, 0.1))
            group.gravityAngle = ga[0];

		//life : Float
        var li : Array<Float> = [group.life];
        if(Inspector.dragFloats("Life", uID, li, 0.1))
            group.life = li[0];

        //lifeRand : Float
        var lir : Array<Float> = [group.lifeRand];
        if(Inspector.dragFloats("Life rand", uID, lir, 0.1))
            group.lifeRand = lir[0];

		//speed : Float
        var sp : Array<Float> = [group.speed];
        if(Inspector.dragFloats("Speed", uID, sp, 0.1))
            group.speed = sp[0];

		//speedRand : Float
        var spr : Array<Float> = [group.speedRand];
        if(Inspector.dragFloats("Speed rand", uID, spr, 0.1))
            group.speedRand = spr[0];

        //speedIncr : Float
        var spi : Array<Float> = [group.speedIncr];
        if(Inspector.dragFloats("Speed incr", uID, spi, 0.1))
            group.speedIncr = spi[0];

	    //emitMode : PartEmitMode
        var i = Inspector.enumDropdown("EmitMode", uID, PartEmitMode, group.emitMode.getIndex());
        if(i != group.emitMode.getIndex())
            group.emitMode = haxe.EnumTools.createByIndex(PartEmitMode, i);

        //emitDist : Float
        var ed : Array<Float> = [group.emitDist];
        if(Inspector.dragFloats("Emit dist", uID, ed, 0.1))
            group.emitDist = ed[0];

        //emitDistY : Float
        var edy : Array<Float> = [group.emitDistY];
        if(Inspector.dragFloats("Emit dist y", uID, edy, 0.1))
            group.emitDistY = edy[0];

		//emitAngle : Float
        var ea : Array<Float> = [group.emitAngle];
        if(Inspector.dragFloats("Emit angle", uID, ea, 0.1))
            group.emitAngle = ea[0];

        //emitDelay : Float
        var ede : Array<Float> = [group.emitDelay];
        if(Inspector.dragFloats("Emit delay", uID, ede, 0.1))
            group.emitDelay = ede[0];

        //emitSync : Float
        var es : Array<Float> = [group.emitSync];
        if(Inspector.dragFloats("Emit sync", uID, es, 0.1))
            group.emitSync = es[0];

        //fadeIn : Float
        var fi : Array<Float> = [group.fadeIn];
        if(Inspector.dragFloats("Fade in", uID, fi, 0.1))
            group.fadeIn = fi[0];

		//fadeOut : Float
        var fo : Array<Float> = [group.fadeOut];
        if(Inspector.dragFloats("Fade out", uID, fo, 0.1))
            group.fadeOut = fo[0];

        //fadePower : Float
        var fp : Array<Float> = [group.fadePower];
        if(Inspector.dragFloats("Fade power", uID, fp, 0.1))
            group.fadePower = fp[0];

        //isRelative : Bool
        var ir : Bool = Inspector.checkbox("Is relative", uID, group.isRelative);
        if(ir != group.isRelative)
            group.isRelative = ir;
    }
    //#endregion

    //-------------------------------
    //#region Static API
    //-------------------------------
    static function initData()
    {
        data = new StringMap<ParticleOptions>();
        var obj : Dynamic = Unserializer.run(hxd.Res.sav.particles.entry.getBytes().toString());
        data = cast obj;
    }

    static function saveData()
    {
        SaveLoader.saveData("particles", data);
    }
    //#endregion

    //-------------------------------
    //#region Getters & Setters
    //-------------------------------
    function set_loop(v : Bool) : Bool
    {
        loop = v;

        if(loop)
            particles.onEnd = () -> return;
        else
            particles.onEnd = stop;

        return loop;
    }

    override function set_gameObject(go : GameObject) : GameObject @:privateAccess
    {
        go.obj = particles;

        if(gameObject != null)
        {
            gameObject.obj = new Object();
        }

        return super.set_gameObject(go);
    }
    //#endregion
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