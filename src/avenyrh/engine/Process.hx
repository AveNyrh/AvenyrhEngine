package avenyrh.engine;

class Process implements IGarbageCollectable
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
     * Unique ID used to set each process uID
     */
    static var UNIQ_ID = 0;

    /**
     * Name of the process
     */
     public var name (default, null) : String;
    /**
     * Unique ID
     */
    public var uID (default, null) : Int;
    /**
     * Is the process in pause
     */
    public var paused (default, null) : Bool;
    /**
     * Is the process destroyed
     */
    public var destroyed (default, null) : Bool;
    /**
     * Root of the graphic layer
     */
    public var root : Null<h2d.Layers>;
    /**
     * Width of the Window
     */
    public var width (get, never) : Int;
    /**
     * Height of the Window
     */
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
        uID = UNIQ_ID++;
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

    public function update(dt : Float) { if(paused || destroyed) return; }
    
    public function postUpdate(dt : Float) { if(paused || destroyed) return; }
    
    public function onResize() { }
    
    private function onDispose() { destroyed = true; }
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

    public function toString() : String
    {
        return name + " : " + uID;
    }
    //#endregion
    
    //-------------------------------
    //#region Public static API
    //-------------------------------    
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
     * Updates all process
     * @param dt Delta time
     */
    @:allow(Boot)
    private static function updateAll(dt : Float) 
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