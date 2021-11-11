package avenyrh.scene;

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
    public var miscInspectable : Array<IInspectable>;

    var allGO : Array<GameObject> = [];

    var rootGo : GameObject;

    var goToRemove : Array<GameObject> = [];

    override public function new() 
    {
        super(StringUtils.getClass(this));
        paused = true;

        createRoot(Process.S2D);

        miscInspectable = [];

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

        if(rootGo == null)
            rootGo = new GameObject("Root");
        
        paused = false;

        added();
    }

    override function onResize() 
    {
        super.onResize();

        for (go in allGO)
            go.onResize();
    }

    #if avenyrhEditor
    var renderTarget : h3d.mat.Texture = null;
    var renderS2d : h2d.Scene = null;

    @:noCompletion
    function _renderInEditor(engine : h3d.Engine, sceneWindow : avenyrh.editor.SceneWindow) 
    {
        //Create new scene to render
        if(renderS2d == null)
            renderS2d = new h2d.Scene();

        //Create target texture
        if(renderTarget == null)
            renderTarget = new h3d.mat.Texture(sceneWindow.width, sceneWindow.height, [Target]);

        //Resize render target if necessary
        if(sceneWindow.width != renderTarget.width || sceneWindow.height != renderTarget.height)
        {
            renderTarget.resize(sceneWindow.width, sceneWindow.height);
            renderS2d.scaleMode = Stretch(sceneWindow.width, sceneWindow.height);
        }

        //Clear the render target
        renderTarget.dispose();

        //Add the root to the render scene
        renderS2d.addChild(root);

        //Push new render targe
        engine.pushTarget(renderTarget);

        //Render the scene
        renderS2d.render(engine);

        //Set the scene texture of the windowScene
        sceneWindow.sceneTex = renderTarget;
        
        //Pop the render target
        engine.popTarget();

        //Render scene for ImGui
        Process.S2D.render(engine);

        //Add the root back to the correct scene
        Process.S2D.addChild(root);
    }
    #end
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
        if(rootGo == null)
            return;

        allGO.push(gameObject);
        
        if(gameObject.parent == null)
            gameObject.parent = rootGo;
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

    public override function toString() : String 
    { 
        return 'Scene $name';
    }
    //#endregion
}