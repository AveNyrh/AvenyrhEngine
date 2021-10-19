package avenyrh.engine;

import avenyrh.physic.PhysicGameObject;
import avenyrh.gameObject.ParticleComponent;
import h2d.Console;
import avenyrh.InputManager;

class Engine extends Process
{
    public static var instance (default, null) : Engine;

    public static var console (default, null) : Console;

    public var fixedFPS : Int = 30;

    var currentTime : Float = 0;

    public function new(s : h2d.Scene, engine : h3d.Engine, ?initScene : Scene) 
    {
        super("Engine");

        instance = this;

        engine.backgroundColor = Color.iDARKBLUE;

        //Engine settings
        hxd.Timer.wantedFPS = EngineConst.FPS;
        @:privateAccess EngineConst.onFPSChanged = () -> hxd.Timer.wantedFPS = EngineConst.FPS;

        createRoot(s);
        Process.S2D = s;

        //Scene manager
        @:privateAccess SceneManager.init(this, initScene);

        //Resources
		#if debug
		hxd.Res.initLocal();
        #else
        hxd.Res.initEmbed();
        #end

        //Console
        console = new h2d.Console(hxd.res.DefaultFont.get(), s);
        console.shortKeyChar = "²".code;

        //Inspector
        #if inspector
        new Inspector();
        #end

        //Init options
        InputManager.init();
        new Tweeny("Tweeny", this);
        @:privateAccess ParticleComponent.initData();
        #if physic
        @:privateAccess PhysicGameObject.initData();
        #end
    }

    //-------------------------------
    //#region Public API
    //-------------------------------
    public override function update(dt : Float)
    {
        super.update(dt);

        currentTime += dt;
        if(currentTime >= 1 / fixedFPS)
        {
            Process._fixedUpdate(this, currentTime);
            currentTime = 0;
        }

        GamePad.lateUpdateAll();
    }
    //#endregion

    //-------------------------------
    //#region Private API
    //-------------------------------
    //#endregion
}