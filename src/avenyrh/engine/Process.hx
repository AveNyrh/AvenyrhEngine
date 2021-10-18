package avenyrh.engine;

import avenyrh.imgui.ImGui;

@:rtti
class Process extends Uniq implements IInspectable
{
    /**
     * All process at the root
     */
    static var ROOTS : Array<Process> = [];

    /**
     * Scene s2d
     */
    public static var S2D : h2d.Scene;

    /**
     * Name of the process
     */
    @hideInInspector
    public var name (default, null) : String;

    /**
     * Is the process in pause
     */
    @hideInInspector
    public var paused (default, null) : Bool;

    /**
     * Is the process destroyed
     */
    @hideInInspector
    public var destroyed (default, null) : Bool;

    /**
     * Root of the graphic layer
     */
    public var root : Null<h2d.Layers>;

    /**
     * Width of the Window
     */
    @hideInInspector
    public var width (get, never) : Int;

    /**
     * Height of the Window
     */
    @hideInInspector
    public var height (get, never) : Int;

    /**
     * Time elapsed since the start of the Engine
     */
    public static var time (default, null) : Float;

    var parent : Process;

    var children : Array<Process>;
    
    public function new(name : String, ?parent : Process) 
    {
        this.name = name;
        uID = Uniq.UNIQ_ID++;
        paused = false;
        destroyed = false;
        children = [];

        if (parent == null)
			ROOTS.push(this);
		else
            parent.addChild(this);
        
        init();
    }

    //-------------------------------
    //#region Overridable functions
    //-------------------------------
    public function init() { }

    public function update(dt : Float) { }
    
    public function postUpdate(dt : Float) { }

    public function fixedUpdate(dt : Float) { }
    
    public function onResize() { }
    
    private function onDispose() { destroyed = true; }

    /**
     * Override this to draw custom informations on the inspector window 
     */
    private function drawInfo() 
    { 
        Inspector.drawInInspector(this);
    }
    //#endregion

    //-------------------------------
    //#region Private API
    //-------------------------------
    /**
     * Creates the root for graphics
     * @param ctx Normally s2d
     */
    function createRoot(?ctx : h2d.Object, ?layer : Int = 0)
    {
        if(root != null)
			throw '[Process ${name}] : root already created !';

        if(ctx == null) 
        {
			if(parent == null || parent.root == null)
                throw '[Process ${name}] : context required';
            
			ctx = parent.root;
        }
        
        root = new h2d.Layers(null);
        ctx.addChildAt(root, layer);
        time = 0;
    }

    function getDefaultFrameRate() : Float 
    {
		return hxd.Timer.wantedFPS;
	}
    //#endregion
    
    //-------------------------------
    //#region Public API
    //-------------------------------
    /**
     * Puts the process in pause
     */
    public function pause()
    {
        paused = true;
    }

	/**
	 * Unpauses the process
	 */
    public function resume() 
    {
        paused = false;
    }

	/**
	 * Toggles the pause of the process
	 */
    public function togglePause() 
    {
        paused ? resume() : pause();
    }

	/**
	 * Destroys this process
	 */
    public function destroy() 
    {
        destroyed = true;

        for(c in children)
            c.destroy();
    }

    /**
     * Adds the process in parameter as a child of this one
     * @param p child
     */
    public function addChild(p : Process) 
    {
        if (p.parent == null) 
            ROOTS.remove(p);
        else 
            p.parent.children.remove(p);

		p.parent = this;
		children.push(p);
    }
    
    /**
     * Removes the process in parameter from children
     * @param p child to remove
     */
    public function removeChild( p : Process ) 
    {
        if(p.parent != this) 
            throw '[Process ${name}] : Invalid parent access';

		p.parent = null;
		children.remove(p);
    }
    
    /**
     * Destroys all process in children
     */
    public function killAllChildrenProcesses() 
    {
		for(p in children)
			p.destroy();
    }

    @:noCompletion
    public function drawInspector()
    {
        drawInfo();
    }

    @:noCompletion
    public function drawHierarchy() : Null<IInspectable>
    {
        var inspec : Null<IInspectable> = null;
        var i : Null<IInspectable> = null;

        if(ImGui.selectable('$name###$name$uID', this == Inspector.currentInspectable))
            inspec = this;

        for(c in children)
        {
            var ci : IInspectable = c.drawHierarchy();

            if(ci != null && i == null)
                i = ci;
        }

        if(i != null && inspec == null)
            inspec = i;

        return inspec;
    }

    public function toString() : String
    {
        return name + " : " + uID;
    }
    //#endregion
    
    //-------------------------------
    //#region Static API
    //-------------------------------
    /**
     * Updates all process
     * @param dt Delta time
     */
    @:noCompletion
    public static function updateAll(dt : Float) 
    {
        //Update all
		for (p in ROOTS)
			_update(p, dt);

        //Post update all
		for (p in ROOTS)
			_postUpdate(p, dt);

        _checkDestroyeds(ROOTS);
        
        //Add time
        time += dt;
    }

    /**
     * Resizes all process
     */
    public static function resizeAll() 
    {
		for (p in ROOTS)
			_resize(p);
    }
    //#endregion
    
    //-------------------------------
    //#region Private static API
    //-------------------------------
    /**
     * Updates the process in parameter
     * @param p Process to update
     */
    static function _update(p : Process, dt : Float)
    {
        //Don't update if paused or destroyed
        if(p.paused || p.destroyed)
            return;
        
        //Update
        if(!p.paused && !p.destroyed)
            p.update(dt);
        
        //Update children
        if(!p.paused && !p.destroyed)
			for (proc in p.children)
				_update(proc, dt);
    }

    /**
     * Called after the update
     * @param p Process to post update
     */
    static function _postUpdate(p : Process, dt : Float) 
    {
        //Don't update if paused or destroyed
		if( p.paused || p.destroyed )
			return;

        //Post update
		p.postUpdate(dt);

        //Post update children
		if( !p.destroyed )
			for (c in p.children)
				_postUpdate(c, dt);
    }

    /**
     * Called at a fixed interval
     * @param p Process to fixed update
     */
    static function _fixedUpdate(p : Process, dt : Float) 
    {
        //Don't update if paused or destroyed
		if( p.paused || p.destroyed )
			return;

        //Fixed update
		p.fixedUpdate(dt);

        //Post update children
		if( !p.destroyed )
			for (c in p.children)
				_fixedUpdate(c, dt);
    }
    
    /**
     * Disposes of every process destroyed in the list in parameter
     * @param ps List of process to clean
     */
    static function _checkDestroyeds(ps : Array<Process>) 
    {
		var i = 0;
        while (i < ps.length) 
        {
			var p = ps[i];
			if(p.destroyed)
				_dispose(p);
            else 
            {
				_checkDestroyeds(p.children);
				i++;
			}
		}
    }
    
    /**
     * Disposes and clean the process in parameter
     * @param p Proces to dispose
     */
    static function _dispose(p : Process) 
    {
		//Destroy children
		for(p in p.children)
            p.destroy();
        
		_checkDestroyeds(p.children);

		//Unregister from lists
		if (p.parent != null)
			p.parent.children.remove(p);
		else
			ROOTS.remove(p);

		//Remove from graphic root
		if( p.root!=null )
			p.root.remove();

		//Call overridable
		p.onDispose();

        // Clean up
        p.root = null;
		p.parent = null;
		p.children = null;
    }
    
    /**
     * Resizes the process in parameter and its children
     * @param p Process to resize
     */
    static function _resize(p : Process) 
    {
		if ( !p.destroyed ){
            p.onResize();
            
			for ( p in p.children )
				_resize(p);
		}
    }
    //#endregion
    
    //-------------------------------
    //#region Getters & Setters
    //-------------------------------
    inline function get_width() : Int
    {
        return hxd.Window.getInstance().width;    
    }

    inline function get_height() : Int
    {
        return hxd.Window.getInstance().height;    
    }
    //#endregion
}