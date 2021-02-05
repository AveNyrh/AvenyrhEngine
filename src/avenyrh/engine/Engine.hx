package avenyrh.engine;

import h2d.Font;
import h2d.Console;
import avenyrh.InputManager;

class Engine extends Process
{
    public static var instance (default, null) : Engine;

    public static var console (default, null) : Console;

    /**
     * Garbage collector
     */
    public var gc (default, null) : Array<IGarbageCollectable>;

    public var currentScene (default, null) : Scene;

    public function new(s : h2d.Scene, ?initScene : Scene) 
    {
        super("Engine");

        instance = this;

        Boot.instance.engine.backgroundColor = Color.iDARKBLUE;

        //Engine settings
        hxd.Timer.wantedFPS = Const.FPS;
        gc = [];
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
        new Inspector();

        InputManager.init();
        InputConfig.initInputs();
        new Tweeny("Tweeny", this);
        //Init options//
    }

    public override function update(dt : Float)
    {
        super.update(dt);

        GamePad.lateUpdateAll();

        cleanGC();
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

    /**
     * Cleans all garbage
     */
    function cleanGC() 
    {
        if(gc == null || gc.length == 0)
            return;

        for(c in gc)
            c.onDispose();

        gc = [];
    }
}