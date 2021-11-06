package avenyrh;

import avenyrh.scene.SceneManager;
import h2d.Console;
import avenyrh.editor.Editor;
import avenyrh.engine.Engine;
import avenyrh.engine.Process;
import avenyrh.scene.ISceneManagerData;

class EditorApp extends hxd.App
{
    public static var instance (default, null) : EditorApp;
    
    public static var avenyrhEngine (default, null) : Engine;

    public static var console (default, null) : Console;

    var sceneManagerData : ISceneManagerData = null;

    var editor : Editor;

    override public function new(sceneManagerData : ISceneManagerData) 
    {
        this.sceneManagerData = sceneManagerData;

        super();   
    }

    /**
     * Initialize the engine
     */
    override function init() 
    {
        super.init();

        instance = this;

        avenyrhEngine = new Engine(s2d, engine, sceneManagerData);
        
        var win = hxd.Window.getInstance();
        win.title = "Avenyrh Editor";
        @:privateAccess win.window.maximize();

        //Console
        console = new h2d.Console(hxd.res.DefaultFont.get(), s2d);
        console.shortKeyChar = "²".code;

        //Editor
        editor = new Editor();
    }

    /**
     * Update the engine
     * @param dt deltaTime
     */
    override function update(dt : Float) 
    {
        super.update(dt);

        @:privateAccess Process.updateAll(dt);
        
        if(SceneManager.currentScene != null)
            @:privateAccess SceneManager.currentScene._updateInEditor(dt);
    }

    override function onResize() 
    {
        super.onResize();

        @:privateAccess Process.resizeAll();
    }

    override function render(e : h3d.Engine) 
    {
        if(SceneManager.currentScene != null)
            @:privateAccess SceneManager.currentScene._renderInEditor(e, editor.sceneWindow);
    }
}