import examples.src.EditorData;
import avenyrh.EntryPoint;
import examples.src.SceneManagerData;

class Main extends EntryPoint
{
    /**
     * Main
     */
    static function main() 
    {
        new Main();
    }

    /**
     * Initialize custom sceneManagerData
     */
    function init() 
    {
        sceneManagerData = new SceneManagerData();
        editorData = new EditorData();
    }
}