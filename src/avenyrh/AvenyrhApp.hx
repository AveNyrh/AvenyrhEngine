package avenyrh;

import avenyrh.engine.Engine;
import avenyrh.engine.Process;
import avenyrh.scene.ISceneManagerData;
import avenyrh.editor.IEditorData;

class AvenyrhApp extends hxd.App
{
    public static var instance (default, null) : AvenyrhApp;
    
    public static var avenyrhEngine (default, null) : Engine;

    var sceneManagerData : ISceneManagerData = null;

    var editorData : IEditorData = null;

    override public function new(sceneManagerData : ISceneManagerData,editorData : IEditorData) 
    {
        this.sceneManagerData = sceneManagerData;
        this.editorData = editorData;

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
    }

    /**
     * Update the engine
     * @param dt deltaTime
     */
    override function update(dt : Float) 
    {
        super.update(dt);
        
        @:privateAccess Process.updateAll(dt);
    }

    override function onResize() 
    {
        super.onResize();

        @:privateAccess Process.resizeAll();
    }
}