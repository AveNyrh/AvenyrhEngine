package avenyrh.gameObject;

import h2d.Object;

class ObjectComponent extends GraphicComponent
{
    public var object (default, null) : Object;

    @hideInInspector
    public var layer (default, null) : Int;

    override public function new(?name : String, ?parent : Object, ?layer : Int = 0) 
    {
        super(name);

        this.layer = layer;
        object = new Object(parent);
    }

    override function set_gameObject(go : GameObject) : GameObject 
    {
        if(gameObject != null)
            return gameObject;

        if(object.parent != null)
            return super.set_gameObject(go);

        var p : GameObject = go;
        var graph : Null<GraphicComponent>;
        var added : Bool = false;
        while(p != null)
        {
            p = p.parent;

            if(p == null)
                break;

            graph = p.getComponent(GraphicComponent);

            if(graph != null)
            {
                graph.getObject().addChild(object);
                added = true;
                break;
            }
        }

        if(!added)
            go.scene.scroller.addChildAt(object, layer);

        return super.set_gameObject(go);
    }

    public function getObject() : Object { return object; }
}