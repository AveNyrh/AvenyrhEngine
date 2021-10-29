package avenyrh.engine;

class SceneManager
{
    /**
     * Callback when a scene is added
     */
    public static var OnSceneAdded : Scene -> Void = null;

    /**
     * Callback when a scene is removed
     */
    public static var OnSceneRemoved : Scene -> Void = null;

    static var avenyrhEngine : Engine = null;

    static var activeScenes : Array<Scene> = [];

    //-------------------------------
    //#region Static API
    //-------------------------------

    /**
     * Called by the engine
     * @param engine 
     * @param initScene 
     */
    static function init(engine : Engine, ?initScene : Scene)
    {
        avenyrhEngine = engine;
        activeScenes = [];

        if(initScene != null)
            addScene(initScene);
    }

    /**
    * Adds a new scene to be loaded by the engine
    * @param scene The new scene to be loaded
    * @param removeCurrent Remove the first scene and take its place, set it to false to add to the currentScene
    * @return The scene that was loaded
    */
	public static function addScene(scene : Scene, ?removeCurrent : Bool = true) : Scene
    {
        if (activeScenes.length != 0 && removeCurrent)
        {
            removeScene(activeScenes[0]);
            activeScenes.insert(0, scene);
        }
        else
        {
            activeScenes.push(scene);
        }
        
        avenyrhEngine.addChild(scene);
        scene._added();

        if(OnSceneAdded != null)
            OnSceneAdded(scene);

        return scene;
    }

    /**
     * Removes a scene from the screen
     * @param scene Scene to remove
     */
    public static function removeScene(scene : Scene) 
    {
        if(!activeScenes.contains(scene))
            return;

        activeScenes.remove(scene);
        avenyrhEngine.removeChild(scene);
        scene.removed();

        if(OnSceneRemoved != null)
            OnSceneRemoved(scene);
    }
    //#endregion

    //-------------------------------
    //#region Getters & Setters
    //-------------------------------
    /**
     * Scene on top of the list, should be the main scene
     */
    public static var currentScene (get, never) : Scene; static inline function get_currentScene() return activeScenes[0];

    /**
     * Number of active scenes
     */
    public static var sceneCount (get, never) : Int; static inline function get_sceneCount() return activeScenes.length;
    //#endregion
}