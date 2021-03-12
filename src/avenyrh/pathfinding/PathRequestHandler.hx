package avenyrh.pathfinding;

import avenyrh.engine.Process;
import avenyrh.utils.Queue;
import avenyrh.Vector2;

/**
 * Queues pathfinding requests for them to be handled one at a time
 */
class PathRequestHandler extends Process
{
    var pathfinding : Pathfinding;

    var isProcessingPath : Bool;

    var pathRequestQueue : Queue<PathRequest>;

    var currentPathRequest : Null<PathRequest>;

    public function new(name : String, ?parent : Process, pf : Pathfinding)
    {
        super(name, parent);

        pathfinding = pf;
        @:privateAccess pathfinding.pathRequestHandler = this;
        isProcessingPath = false;
        pathRequestQueue = new Queue<PathRequest>();
    }

    //-------------------------------
    //#region Public API
    //-------------------------------
    /**
     * Put a path finding request in the queue
     */
    public function requestPath(pathStart : Vector2, pathEnd : Vector2, callback : (Array<Vector2>, Bool) -> Void)
    {
        var newRequest : PathRequest = {pathStart : pathStart, pathEnd : pathEnd, callback : callback};
        pathRequestQueue.enqueue(newRequest);
        tryProcessNext();
    }
    //#endregion

    //-------------------------------
    //#region Private API
    //-------------------------------
    override function postUpdate(dt:Float) 
    {
        super.postUpdate(dt);

        if(!isProcessingPath)
            tryProcessNext();
    }

    /**
     * Process the next path finding request if possible
     */
    function tryProcessNext() 
    {
        if(!isProcessingPath && pathRequestQueue.length > 0)
        {
            currentPathRequest = pathRequestQueue.dequeue();
            isProcessingPath = true;
            pathfinding.findPath(currentPathRequest.pathStart, currentPathRequest.pathEnd);
        }
    }

    /**
     * Called when a path finding request has finished processing
     */
    function finishedProcessingPath(path : Array<Vector2>, succes : Bool) 
    {
        currentPathRequest.callback(path, succes);
        isProcessingPath = false;
    }
    //#endregion
}

typedef PathRequest = 
{
    pathStart : Vector2,
    pathEnd : Vector2,
    callback : (Array<Vector2>, Bool) -> Void
}