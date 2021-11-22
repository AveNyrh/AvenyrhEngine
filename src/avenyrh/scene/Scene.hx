package avenyrh.scene;

using Lambda;
import haxe.Int64;
import h2d.Flow;
import avenyrh.engine.Process;
import avenyrh.utils.StringUtils;
import avenyrh.gameObject.GameObject;
import avenyrh.editor.IInspectable;

@:allow(avenyrh.scene.SceneManager)
class Scene extends Process
{
    /**
     * Parent for the scene graphs
     */
    @noSerial
    public var scroller : h2d.Layers;

    /**
     * UI container
     */
    @noSerial
    public var ui : Flow;
    
    /**
     * Current active camera in the scene
     */
    @noSerial
    public var camera : Camera = null;

    @noSerial
    public var miscInspectable : Array<IInspectable> = [];

    var allGO : Array<GameObject> = [];

    @serializable
    var rootGO : Array<GameObject> = [];

    var goToRemove : Array<GameObject> = [];

    override public function new() 
    {
        super(StringUtils.getClass(this));
        paused = true;

        createRoot(Process.S2D);

        if(camera == null)
            camera = new Camera("Camera", this);
    }

    //-------------------------------
    //#region Private API
    //-------------------------------
    /**
     * Called when added to the engine
     */
    @:noCompletion
    function _added() 
    {
        if(ui == null)
        {
            ui = new Flow();
            root.add(ui, 1);
            ui.minWidth = ui.maxWidth = width;
            ui.minHeight = ui.maxHeight = height;
        }

        if(scroller == null)
        {
            scroller = new h2d.Layers();
            root.add(scroller, 0);
        }
        
        paused = false;

        added();
    }

    override function onResize() 
    {
        super.onResize();

        for (go in allGO)
            go.onResize();
    }
    //#endregion

    //-------------------------------
    //#region Overridable functions
    //-------------------------------
    /**
     * Override this to instantiate things when the scene is added to the engine
     */
    public function added() { }

    public function removed()
    {
        Process._dispose(this);
    }

    public override function update(dt : Float) 
    {
        super.update(dt);

        for(go in allGO)
            go._update(dt);

        cleanGameObjects();
    }

    public override function postUpdate(dt : Float) 
    {
        super.postUpdate(dt);

        for(go in allGO)
            go._postUpdate(dt);

        cleanGameObjects();
    }

    public override function fixedUpdate(dt : Float) 
    {
        super.fixedUpdate(dt);

        for(go in allGO)
            go._fixedUpdate(dt);
    }

    /**
     * Called when the scene is destroyed
     */
    override function onDispose() 
    {
        super.onDispose();

        //Dispose GameObjects
        for(go in allGO)
            go.removed();

        allGO = [];

        //Remove root graph
        root.remove();
    }
    //#endregion

    //-------------------------------
    //#region Public API
    //-------------------------------
    /**
     * Adds a gameObject to the scene so that it can be updated
     * @param gameObject GameObject to add to the scene
     */
    public function addGameObject(gameObject : GameObject) 
    {
        allGO.push(gameObject);
    }

    /**
     * Removes a gameObject from the scene
     * @param gameObject GameObject to remove
     */
    public function removeGameObject(gameObject : GameObject) 
    {
        if(!hasGameObject(gameObject))
            return;

        goToRemove.push(gameObject);
        gameObject.enable = false;
    }

    function cleanGameObjects()
    {
        if(goToRemove.length == 0)
            return;

        for(go in goToRemove)
        {
            if(allGO.contains(go))
                allGO.remove(go);

            if(rootGO.contains(go))
                rootGO.remove(go);
            
            go.removed();
        }

        goToRemove = [];
    }

    /**
     * Returns true if this scene contains the gameObject
     * @param component Wanted gameObject
     * @return True if it contains, false if not
     */
    public function hasGameObject(gameObject : GameObject) : Bool 
    {
        if(gameObject == null)
            return false;

        for(go in allGO)
            if(go.uID == gameObject.uID)
                return true;
            
        return false;
    }

    public inline function getGameObjectFromUID(id : String) : GameObject
    {
        return allGO.find((go) -> Int64.toStr(go.uID) == id);
    }

    public override function toString() : String 
    { 
        return 'Scene $name';
    }
    //#endregion
}