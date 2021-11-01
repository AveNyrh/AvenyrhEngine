package avenyrh.scene;

/**
 * When implementing this, import all custom scenes, DCE will remove the class if not
 */
interface ISceneManagerData 
{
    /**
     * Path of the scenes root folder
     */
    var scenesFolderPath (default, null) : String;

    /**
     * Array of all scene path to be included
     */
    var scenes (default, null) : Array<String>;
}