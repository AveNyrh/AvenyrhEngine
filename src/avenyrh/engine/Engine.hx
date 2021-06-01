package avenyrh.engine;

import avenyrh.physic.PhysicGameObject;
import avenyrh.gameObject.ParticleComponent;
import h2d.Console;
import avenyrh.InputManager;

class Engine extends Process
{
    public static var instance (default, null) : Engine;

    public static var console (default, null) : Console;

    public var currentScene (default, null) : Scene;

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
        @:privateAccess PhysicGameObject.initData();
    }

    //-------------------------------
    //#region Public API
    //-------------------------------
    public override function update(dt : Float)
    {
        super.update(dt);

        GamePad.lateUpdateAll();

        currentTime += dt;
        if(currentTime >= 1 / fixedFPS)
        {
            Process._fixedUpdate(this, currentTime);
            currentTime = 0;
        }
    }

    /**
    * Adds a new scene to be loaded by the engine
    * @param scene The new scene to be loaded
    * @return The scene that was loaded
    */
	public function addScene(scene : Scene, ?removeCurrent : Bool = true) : Scene
    {
        if (currentScene != null && removeCurrent)
            removeScene(currentScene);
        
        currentScene = scene;
        addChild(scene);
        currentScene._added();

        return scene;
    }

    /**
     * Removes a scene from the screen
     * @param scene 
     */
    public function removeScene(scene : Scene) 
    {
        if(scene == currentScene)
            currentScene = null;

        removeChild(scene);
        scene.removed();
    }
    //#endregion

    //-------------------------------
    //#region Private API
    //-------------------------------
    //#endregion
}