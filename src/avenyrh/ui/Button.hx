package avenyrh.ui;

import h2d.Font;
import h2d.RenderContext;
import hxd.Event;
import hxd.Event.EventKind;
import h2d.Text;
import h2d.Object;
import h2d.Tile;
import h2d.Interactive;
import h2d.col.Collider;

class Button extends Interactive
{
    /**
     * Current state of the button
     */
    public var state : ButtonState;
    /**
     * Use color graphs or tile graphs
     */
    public var useColor :  Bool;
    /**
     * Idle graphs
     */
    public var idle : ButtonStateGraph;
    /**
     * Hover graphs
     */
    public var hover : ButtonStateGraph;
    /**
     * Pressed graphs
     */
    public var press : ButtonStateGraph;
    /**
     * Hold graphs
     */
    public var hold : ButtonStateGraph;
    /**
     * Disable graphs
     */
    public var disable : ButtonStateGraph;
    /**
     * If false, it can't be interacted with
     */
    public var interactable : Bool;
    /**
     * Text displayed on the button
     */
    var txt : Null<Text>;

    var pressed : Bool;
    
    public function new(parent : Object, width : Float, height : Float, ?shape : Collider) 
    {
        super(width, height, parent, shape);

        useColor = true;
        interactable = true;
        pressed = false;

        idle = new ButtonStateGraph(width, height, getDefaultColor(Idle));
        hover = new ButtonStateGraph(width, height, getDefaultColor(Hover));
        press = new ButtonStateGraph(width, height, getDefaultColor(Press));
        hold = new ButtonStateGraph(width, height, getDefaultColor(Hold));
        disable = new ButtonStateGraph(width, height, getDefaultColor(Disable));
    }

    //-------------------------------
    //#region Public API
    //-------------------------------
    /**
     * Sets the text inside the button
     */
    public function setText(text : String, ?font : Font, ?align : Align = Align.Center, ?color : Int, ?c : h3d.Vector) 
    {
        var f = font == null ? hxd.res.DefaultFont.get() : font;

        if(color == null)
            color = Color.iBLACK;

        if(txt != null)
            txt.remove();

        txt = new Text(f, this);

        txt.maxWidth = width;
        txt.textAlign = align;
        txt.text = text;
        txt.x = 0;
        txt.y = (height - txt.textHeight) / 2;

        if(c != null)
            txt.color = c;
        else
            txt.color.setColor(color);
    }

    override public function handleEvent(e : Event)
    {
        if(!interactable)
            return;

        if (e.kind == EventKind.EPush)
        {
            pressed = true; 
        }
        else if (e.kind == EventKind.ERelease || e.kind == EventKind.EReleaseOutside)
        {
            pressed = false;
        }

        super.handleEvent(e);
    }
    //#endregion

    //-------------------------------
    //#region Private API
    //-------------------------------
    override function draw(ctx : RenderContext)
    {
        if(!interactable)
            state = Disable;
        else
        {
            if (isOver())
            {
                state = pressed ? Press : Hover;
            }
            else 
            {
                state = pressed ? Hold : Idle;
            }
        }

        emitTile(ctx, getGraph());
    }

    /**
     * Returns the right tile
     */
    function getGraph() : Tile
    {
        switch (state)
        {
            case Idle :
                return useColor ? idle.tile : idle.customTile;
            case Hover :
                return useColor ? hover.tile : hover.customTile;
            case Press :
                return useColor ? press.tile : press.customTile;
            case Hold :
                return useColor ? hold.tile : hold.customTile;
            case Disable :
                return useColor ? disable.tile : disable.customTile;
            default:
                throw "Button state not found";

        }
    }

    /**
     * Default values for colors
     */
    function getDefaultColor(state : ButtonState) : Int 
    {        
        switch (state)
        {
            case Idle :
                return Color.iWHITE;
            case Hover :
                return Color.iLIGHTGREY;
            case Press :
                return Color.iGREY;
            case Hold :
                return Color.iGREY;
            case Disable :
                return Color.iBLACK;
            default:
                throw "Button state not found";

        }
    }
    //#endregion
}

class ButtonStateGraph
{
    public var color (default, set) : Int;
    public var alpha (default, set) : Int;
    public var tile (default, null) : Tile;
    public var customTile : Null<Tile>;

    var width : Float;
    var height : Float;

    public function new(width : Float, height : Float, color : Int, ?alpha : Int = 1, ?t : Tile)
    {
        this.width = width;
        this.height = height;

        this.color = color;
        this.alpha = alpha;

        tile = Tile.fromColor(color, Std.int(width), Std.int(height), alpha);

        customTile = t;
    }

    function set_color(c : Int) : Int 
    {
        this.color = c;
        tile = Tile.fromColor(color, Std.int(width), Std.int(height), alpha);

        return color;
    }

    function set_alpha(a : Int) : Int 
    {
        this.alpha = a;
        tile = Tile.fromColor(color, Std.int(width), Std.int(height), alpha);

        return alpha;
    }
}

enum ButtonState
{
    Idle;
    Hover;
    Press;
    Hold;
    Disable;
}