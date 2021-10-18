package avenyrh.gameObject;

import h2d.HtmlText;
import h2d.Object;
import h2d.Font;

class TextComponent extends GraphicComponent
{
    public var htmlText (default, null) : HtmlText;

    public var text (default, set) : String;

    @hideInInspector
    public var layer (default, null) : Int;

    override public function new(?name : String, ?parent : Object, ?layer : Int = 0, font : Font) 
    {
        super(name == null ? "Text" : name);

        this.layer = layer;
        htmlText = new HtmlText(font, parent);
    }

    //-------------------------------
    //#region Getters & Setters
    //-------------------------------
    function set_text(t : String) : String
    {
        htmlText.text = t;

        return htmlText.text;
    }

    override function set_gameObject(go : GameObject) : GameObject 
    {
        if(gameObject != null)
            return gameObject;

        if(htmlText.parent != null)
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
                graph.getObject().addChild(htmlText);
                added = true;
                break;
            }
        }

        if(!added)
            go.scene.scroller.addChildAt(htmlText, layer);

        return super.set_gameObject(go);
    }

    public function getObject() : Object { return htmlText; } 
    //#endregion
}