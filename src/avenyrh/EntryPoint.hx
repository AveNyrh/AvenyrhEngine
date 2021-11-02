package avenyrh;

import avenyrh.scene.ISceneManagerData;

abstract class EntryPoint
{
    var sceneManagerData : ISceneManagerData = null;

    function new()
    {
        //Call init to retrieve custom sceneManagerData
        init();

        #if avenyrhEditor
        //If avenyrhEditor is define, create an editor window
        new EditorApp(sceneManagerData);
        #else
        //If avenyrhEditor is not define, create the game window
        new AvenyrhApp(scesceneManagerData);
        #end
    }

    abstract function init() : Void;
}