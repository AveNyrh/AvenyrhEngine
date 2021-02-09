package avenyrh.engine;

import h2d.col.Point;
import h2d.Bitmap;
import h2d.Tile;
import h2d.Text;
import avenyrh.ui.ScrollArea;
import h2d.Object;
import h2d.Flow;
import h2d.Layers;

class Inspector extends Process
{
    /**
     * Is the inspector running
     */
    var enable : Bool;
    /**
     * Current object being inspected
     */
    var currentInspectable : Null<IInspectable>;
    /**
     * Flow container for the inspector
     */
    var flow : Flow;
    /**
     * Background image
     */
    var bg : Bitmap;
    /**
     * Content of the inspector
     */
    var scroll : ScrollArea;
    /**
     * Text in the content
     */
    var text : Text;
    /**
     * Color for the texts
     */
    var textColor : Int = Color.iLIGHTGREY;

    var isDragging : Bool = false;

    var dragOffset : Vector2;

    override public function new() 
    {
        super("Inspector");

        //Register the event
        hxd.Window.getInstance().addEventTarget(onEvent);

        //Create root for graphs
        createRoot(Process.S2D, 100);

        //Create flow container
        flow = new Flow(root);
        flow.maxWidth = EngineConst.INSPECTOR_MAX_WIDTH;
        flow.maxHeight = EngineConst.INSPECTOR_MAX_HEIGHT;
        flow.layout = Vertical;
        flow.horizontalAlign = Middle;
        flow.padding = 10;
        flow.horizontalSpacing = 10;
        flow.setPosition(1000, 60);

        //Background
        bg = new Bitmap(Tile.fromColor(Color.iBLACK, 0.8), flow);
        flow.getProperties(bg).isAbsolute = true;

        //Title
        var t : Text = new Text(hxd.res.DefaultFont.get(), flow);
        t.textAlign = Left;
        t.text = "Inspector\n";
        t.textColor = textColor;
        t.scale(2);

        //Content area
        scroll = new ScrollArea(flow, EngineConst.INSPECTOR_DEFAULT_WIDTH, EngineConst.INSPECTOR_DEFAULT_HEIGHT);
        scroll.allowHorizontal = false;
        scroll.setContentAlign(Middle, Top);

        //Text content
        text = new Text(hxd.res.DefaultFont.get());
        text.maxWidth = scroll.maxWidth;
        text.textAlign = Center;
        scroll.addToContent(text);
        text.textColor = textColor;

        bg.width = flow.getSize().width;
        bg.height = flow.getSize().height;

        close();
    }

    //-------------------------------
    //#region Private API
    //-------------------------------
    override function update(dt:Float) 
    {
        super.update(dt);

        if(hxd.Key.isPressed(hxd.Key.F4))
            enable ? close() : open();
    }

    override function postUpdate(dt:Float) 
    {
        super.postUpdate(dt);

        if(!enable)
            return;

        //If something is being inspected, display the content
        if(currentInspectable != null)
        {
            var s : String = currentInspectable.getInspectorInfo();
            text.text = s;

            updateSize();
        }

        //Dragging
        if(isDragging)
        {
            flow.setPosition(Process.S2D.mouseX + dragOffset.x, Process.S2D.mouseY + dragOffset.y);
        }
    }

    function onEvent(e : hxd.Event) 
    {
        if(!enable)
            return;

        e.propagate = true;

        //Click on the inspector
        if(e.kind == EPush && !scroll.isScrolling)
        {
            var p : Point = new Point(e.relX, e.relY);

            if(flow.getBounds().contains(p))
            {
                isDragging = true;
                dragOffset = new Vector2(flow.getAbsPos().x - e.relX, flow.getAbsPos().y - e.relY);
                return;
            }
        }
        
        //Click on an object
        if(e.kind == EPush)
        {
            var foundInspectable : Bool = false;

            var scene : Scene = Engine.instance.currentScene;
            var ss : Layers = scene.scroller;
            var sui : Flow = scene.ui;

            //Objects
            for(i in 0 ... ss.numChildren)
            {
                var c : Object = ss.getChildAt(i);

                if(Std.isOfType(c, IInspectable))
                {
                    var inspec : IInspectable = cast c;

                    if(inspec.isInBounds(e.relX, e.relY))
                    {
                        currentInspectable = inspec;
                        foundInspectable = true;
                        return;
                    }
                }
            }

            //UI
            for(i in 0 ... sui.numChildren)
            {
                var c : Object = sui.getChildAt(i);

                if(Std.isOfType(c, IInspectable))
                {
                    var inspec : IInspectable = cast c;

                    if(inspec.isInBounds(e.relX, e.relY))
                    {
                        currentInspectable = inspec;
                        foundInspectable = true;
                        return;
                    }
                }
            }
            
            //Reset if cliked outside
            if(!foundInspectable)
            {
                currentInspectable = null;
                text.text = "";
                updateSize();
            }
        }


        if(e.kind == ERelease)
            isDragging = false;
    }

    function updateSize()
    {
        var h : Float = AMath.fclamp(text.getSize().height, 1, EngineConst.INSPECTOR_MAX_HEIGHT);
        scroll.setHeight(Std.int(h));

        bg.width = flow.getSize().width;
        bg.height = flow.getSize().height;
    }
    //#endregion

    //-------------------------------
    //#region Public API
    //-------------------------------
    public function open()
    {
        enable = true;
        flow.visible = true;
        text.text = "";
        updateSize();
    }

    public function close()
    {
        enable = false;
        flow.visible = false;
    }
    //#endregion
}