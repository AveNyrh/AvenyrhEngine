package avenyrh;

import avenyrh.editor.IEditorData;
import avenyrh.scene.ISceneManagerData;

abstract class EntryPoint
{
    var sceneManagerData : ISceneManagerData = null;

    var editorData : IEditorData = null;

    function new()
    {
        //Call init to retrieve custom sceneManagerData
        init();

        #if avenyrhEditor
        //If avenyrhEditor is define, create an editor window
        new EditorApp(sceneManagerData, editorData);
        #else
        //If avenyrhEditor is not define, create the game window
        new AvenyrhApp(scesceneManagerData, ededitorData);
        #end
    }

    abstract function init() : Void;
}