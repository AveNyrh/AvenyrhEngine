package avenyrh.engine;

import avenyrh.scene.ISceneManagerData;
import avenyrh.scene.SceneManager;
import avenyrh.InputManager;
import avenyrh.physic.PhysicGameObject;
import avenyrh.gameObject.ParticleComponent;

class Engine extends Process
{
    public static var instance (default, null) : Engine;

    public var fixedFPS : Int = 30;

    var currentTime : Float = 0;

    public function new(s : h2d.Scene, engine : h3d.Engine, sceneManagerData : ISceneManagerData) 
    {
        super("Engine");

        instance = this;

        engine.backgroundColor = Color.rgbaToInt({r : 20, g : 20, b : 20, a : 255});

        //Engine settings
        hxd.Timer.wantedFPS = EngineConst.FPS;
        @:privateAccess EngineConst.onFPSChanged = () -> hxd.Timer.wantedFPS = EngineConst.FPS;

        createRoot(s);
        Process.S2D = s;

        //Resources
		#if debug
		hxd.Res.initLocal();
        #else
        hxd.Res.initEmbed();
        #end

        //Scene manager
        @:privateAccess SceneManager.init(this, sceneManagerData);

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