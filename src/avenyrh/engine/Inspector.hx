package avenyrh.engine;

import avenyrh.ui.Dropdown;
import h2d.Interactive;
import h2d.TextInput;
import avenyrh.ui.Fold;
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

    var title : Text;

    var isDragging : Bool = false;

    var padding : Int = 10;

    var dragOffset : Vector2;

    var fields : Array<IField>;

    var lock : Bool = false;

    var icons : Array<Tile>;

    override public function new() 
    {
        super("Inspector");

        //Register the event
        hxd.Window.getInstance().addEventTarget(onEvent);

        //Create root for graphs
        createRoot(Process.S2D, 100);

        //Create flow container
        flow = new Flow(root);
        flow.maxHeight = EngineConst.INSPECTOR_MAX_HEIGHT;
        flow.layout = Vertical;
        flow.horizontalAlign = Middle;
        flow.padding = padding;
        flow.horizontalSpacing = 10;
        flow.setPosition(60, 60);

        //Background
        bg = new Bitmap(Tile.fromColor(EngineConst.INSPECTOR_BG_COLOR, 0.8), flow);
        flow.getProperties(bg).isAbsolute = true;

        //Header
        var f : Flow = new Flow(flow);
        f.layout = Stack;
        f.minWidth = EngineConst.INSPECTOR_DEFAULT_WIDTH - 2 * padding;
        f.minHeight = 60;
        //f.debug = true;

        //Title
        title = new Text(hxd.res.DefaultFont.get(), f);
        title.textAlign = Left;
        title.text = "Inspector";
        title.textColor = EngineConst.INSPECTOR_TEXT_COLOR;
        title.scale(2);
        f.getProperties(title).align(Top, Middle);

        //Buttons
        icons = hxd.res.Embed.getResource("avenyrh/engine/icons.png").toTile().split(6);
        var b : InspectorButton = new InspectorButton(f, icons[0], icons[1], EngineConst.INSPECTOR_ICON_ON_COLOR, EngineConst.INSPECTOR_ICON_OFF_COLOR, (v) -> lock = v);
        b.scale(0.3);
        f.getProperties(b).align(Top, Right);
        b = new InspectorButton(f, icons[2], icons[2], EngineConst.INSPECTOR_ICON_ON_COLOR, EngineConst.INSPECTOR_ICON_OFF_COLOR, debugGameObjects);
        b.scale(0.3);
        f.getProperties(b).align(Top, Right);
        f.getProperties(b).offsetX = Std.int(-b.getSize().width - 4);

        //Content area
        scroll = new ScrollArea(flow, EngineConst.INSPECTOR_DEFAULT_WIDTH - 2 * padding, EngineConst.INSPECTOR_DEFAULT_HEIGHT);
        scroll.allowHorizontal = false;
        scroll.setContentAlign(Middle, Top);
        scroll.maskFlow.layout = Vertical;
        scroll.maskFlow.verticalSpacing = 2;

        //Text content
        text = new Text(hxd.res.DefaultFont.get());
        text.maxWidth = scroll.maxWidth;
        text.textAlign = Center;
        scroll.addToContent(text);
        text.textColor = EngineConst.INSPECTOR_TEXT_COLOR;

        bg.width = flow.getSize().width;
        bg.height = flow.getSize().height;

        fields = [];

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
            for(f in fields)
                f.updateDisplay();
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

        e.propagate = false;

        //Click on the inspector
        if(e.kind == EPush && !scroll.isScrolling)
        {
            var p : Point = new Point(e.relX, e.relY);

            if(flow.getBounds().contains(p) && e.relY < title.getSize().height + padding + flow.y)
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
            var insp : Null<IInspectable>  = null;

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
                        insp = inspec;
                        foundInspectable = true;
                        break;
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
                        insp = inspec;
                        foundInspectable = true;
                        break;
                    }
                }
            }

            if(foundInspectable && currentInspectable != insp && !lock)
            {
                //Set info
                fields = [];
                scroll.clearContent();
                currentInspectable = insp;
                currentInspectable.drawInspector(this);
            }
            else
            {
                var p : Point = new Point(e.relX, e.relY);

                if(!flow.getBounds().contains(p) && !lock)
                {
                    //Reset if cliked outside
                    currentInspectable = null;
                    text.text = "";
                    fields = [];
                    scroll.clearContent();
                    updateSize();
                }
            }
        }

        if(e.kind == ERelease)
            isDragging = false;
    }

    function updateSize()
    {
        var h : Float = AMath.fclamp(scroll.getSize().height, 1, EngineConst.INSPECTOR_MAX_HEIGHT);

        bg.width = EngineConst.INSPECTOR_DEFAULT_WIDTH;
        bg.height = h + 2 * padding + title.getSize().height;
    }

    function debugGameObjects(value : Bool)
    {
        var scene : Scene = Engine.instance.currentScene;

        if(scene == null)
            return;

        var ss : Layers = scene.scroller;
        var sui : Flow = scene.ui;

        //Objects
        for(i in 0 ... ss.numChildren)
        {
            var c : Object = ss.getChildAt(i);

            if(Std.isOfType(c, IInspectable))
            {
                var inspec : IInspectable = cast c;

                inspec.debug = value;
            }
        }

        //UI
        for(i in 0 ... sui.numChildren)
        {
            var c : Object = sui.getChildAt(i);

            if(Std.isOfType(c, IInspectable))
            {
                var inspec : IInspectable = cast c;

                inspec.debug = value;
            }
        }
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
        currentInspectable = null;
        fields = [];
        scroll.clearContent();
    }

    public function fold(label : String) : Fold
    {
        var fold : Fold = new Fold(null, label, hxd.res.DefaultFont.get(), EngineConst.INSPECTOR_FOLD_WIDTH, EngineConst.INSPECTOR_FOLD_HEIGHT, EngineConst.INSPECTOR_FOLD_COLOR);
        scroll.addToContent(fold);
        fold.label.textColor = EngineConst.INSPECTOR_TEXT_COLOR;

        var f : Flow = new Flow(fold.container);
        f.layout = Vertical;
        f.minWidth = f.maxWidth = EngineConst.INSPECTOR_FOLD_WIDTH;

        fold.onChange = (v) -> updateSize();
        fold.isOpen = true;
 
        return fold;
    }

    public function field(parent : Fold, label : String, get : Void -> String, set : String -> Void, slider : Bool = false, min : Float = 0, max : Float = 1, canEdit : Bool = true) : Field
    {
        var f : Flow = cast parent.container.getChildAt(0);

        var field : Field = new Field(label, f, EngineConst.INSPECTOR_FIELD_WIDTH, EngineConst.INSPECTOR_FIELD_HEIGHT, get, set);
        f.getProperties(field).offsetX = EngineConst.INSPECTOR_FOLD_WIDTH - EngineConst.INSPECTOR_FIELD_WIDTH;
        field.ti.canEdit = canEdit;

        fields.push(field);

        return field;
    }

    public function doubleField(parent : Fold, labelLeft : String, getLeft : Void -> String, setLeft : String -> Void, labelRight : String, getRight : Void -> String, setRight : String -> Void, slider : Bool = false, min : Float = 0, max : Float = 1, canEdit : Bool = true)
    {
        var f : Flow = cast parent.container.getChildAt(0);
        var flow : Flow = new Flow(f);
        f.minWidth = f.maxWidth = EngineConst.INSPECTOR_FOLD_WIDTH - EngineConst.INSPECTOR_FIELD_WIDTH;
        f.getProperties(flow).offsetX = EngineConst.INSPECTOR_FOLD_WIDTH - EngineConst.INSPECTOR_FIELD_WIDTH;

        var field : Field = new Field(labelLeft, flow, Std.int(EngineConst.INSPECTOR_FIELD_WIDTH / 2), EngineConst.INSPECTOR_FIELD_HEIGHT, getLeft, setLeft);
        field.ti.canEdit = canEdit;
        fields.push(field);

        field = new Field(labelRight, flow, Std.int(EngineConst.INSPECTOR_FIELD_WIDTH / 2), EngineConst.INSPECTOR_FIELD_HEIGHT, getRight, setRight);
        field.ti.canEdit = canEdit;
        fields.push(field);
    }

    public function textLabel(parent : Fold, label : String)
    {
        var f : Flow = cast parent.container.getChildAt(0);

        var label : Label = new Label(label, f, EngineConst.INSPECTOR_FIELD_WIDTH, EngineConst.INSPECTOR_FIELD_HEIGHT);
        f.getProperties(label).offsetX = EngineConst.INSPECTOR_FOLD_WIDTH - EngineConst.INSPECTOR_FIELD_WIDTH;
    }

    public function button(parent : Fold, label : String, cb : Void -> Void)
    {
        var f : Flow = cast parent.container.getChildAt(0);

        var b : ButtonField = new ButtonField(label, f, EngineConst.INSPECTOR_FIELD_WIDTH, EngineConst.INSPECTOR_FIELD_HEIGHT, cb);
        f.getProperties(b).offsetX = EngineConst.INSPECTOR_FOLD_WIDTH - EngineConst.INSPECTOR_FIELD_WIDTH;
    }

    public function boolField(parent : Fold, label : String, get : Void -> Bool, set : Bool -> Void) 
    {
        var f : Flow = cast parent.container.getChildAt(0);

        var b : BoolField = new BoolField(label, f, EngineConst.INSPECTOR_FIELD_WIDTH, EngineConst.INSPECTOR_FIELD_HEIGHT, get, set, icons);
        f.getProperties(b).offsetX = EngineConst.INSPECTOR_FOLD_WIDTH - EngineConst.INSPECTOR_FIELD_WIDTH;

        fields.push(b);
    }

    public function enumField<T>(parent : Fold, label : String, get : Void -> Int, set : Int -> Void, e : Enum<T>) 
    {
        var f : Flow = cast parent.container.getChildAt(0);

        var ef : EnumField<T> = new EnumField(label, f, EngineConst.INSPECTOR_FIELD_WIDTH, EngineConst.INSPECTOR_FIELD_HEIGHT, get, set, e, icons);
        f.getProperties(ef).offsetX = EngineConst.INSPECTOR_FOLD_WIDTH - EngineConst.INSPECTOR_FIELD_WIDTH;

        fields.push(ef);
    }

    public function space(parent : Fold, size : Int)
    {
        var f : Flow = cast parent.container.getChildAt(0);
        
        var b : Bitmap = new Bitmap(Tile.fromColor(EngineConst.INSPECTOR_FIELD_COLOR, EngineConst.INSPECTOR_FIELD_WIDTH, size), f);
        f.getProperties(b).offsetX = EngineConst.INSPECTOR_FOLD_WIDTH - EngineConst.INSPECTOR_FIELD_WIDTH;
    }
    //#endregion
}

class Field extends Flow implements IField
{
    public var get : Void -> String;

    public var set : String -> Void;

    public var ti : TextInput;

    var isChanging : Bool = false;

    override public function new(label : String, parent : Object, width : Int, height : Int, get : Void -> String, set : String -> Void, offsetX : Int = 0) 
    {
        super(parent);

        this.get = get;
        this.set = set;

        layout = Stack;

        minWidth = maxWidth = width;
        minHeight = maxHeight = height;

        backgroundTile = Tile.fromColor(EngineConst.INSPECTOR_FIELD_COLOR, width, height);

        var text : Text = new Text(hxd.res.DefaultFont.get(), this);
        text.text = label;
        text.textColor = EngineConst.INSPECTOR_TEXT_COLOR;
        getProperties(text).align(Top, Left);
        getProperties(text).offsetX = 10;
        getProperties(text).offsetY = Std.int((height - text.textHeight) / 2);

        ti = new TextInput(hxd.res.DefaultFont.get(), this);
        ti.textColor = EngineConst.INSPECTOR_TEXT_COLOR_FIELD;
        getProperties(ti).align(Top, Left);
        getProperties(ti).offsetX = 90 + offsetX;
        getProperties(ti).offsetY = Std.int((height - ti.textHeight) / 2);
        ti.text = get();
        ti.onChange = () ->
        {
            set(ti.text);
            isChanging = true;
        }
        ti.onFocusLost = (e) -> isChanging = false;
    }

    public function updateDisplay()
    {
        if(!isChanging)
            ti.text = get();
    }
}

class Label extends Flow
{
    override public function new(label : String, parent : Object, width : Int, height : Int) 
    {
        super(parent);

        layout = Stack;

        minWidth = maxWidth = width;
        minHeight = maxHeight = height;

        backgroundTile = Tile.fromColor(EngineConst.INSPECTOR_FIELD_COLOR, width, height);

        var text : Text = new Text(hxd.res.DefaultFont.get(), this);
        text.text = label;
        text.textColor = EngineConst.INSPECTOR_TEXT_COLOR;
        getProperties(text).align(Top, Left);
        getProperties(text).offsetX = 10;
        getProperties(text).offsetY = Std.int((height - text.textHeight) / 2);
    }
}

class ButtonField extends Flow
{
    var cb : Void -> Void;

    var inter : Interactive;

    override public function new(label : String, parent : Object, width : Int, height : Int, cb : Void -> Void, offsetX : Int = 0) 
    {
        super(parent);

        this.cb = cb;

        layout = Stack;
        minWidth = maxWidth = width;
        minHeight = maxHeight = height;

        backgroundTile = Tile.fromColor(EngineConst.INSPECTOR_FIELD_COLOR, width, height);

        var text : Text = new Text(hxd.res.DefaultFont.get(), this);
        text.text = label;
        text.textColor = EngineConst.INSPECTOR_TEXT_COLOR;
        getProperties(text).align(Top, Left);
        getProperties(text).offsetX = 10;
        getProperties(text).offsetY = Std.int((height - text.textHeight) / 2);

        inter = new Interactive(width * 0.6, height * 0.8, this);
        inter.backgroundColor = Color.iGREY;
        getProperties(inter).align(Top, Left);
        getProperties(inter).offsetX = 90 + offsetX;
        getProperties(inter).offsetY = Std.int((height - inter.height) / 2);

        inter.onPush = (e) -> 
        {
            inter.backgroundColor = Color.iDARKGREY;
            cb();
        }

        inter.onRelease = (e) -> inter.backgroundColor = Color.iGREY;
        inter.onReleaseOutside = (e) -> inter.backgroundColor = Color.iGREY;
    }
}

class BoolField extends Flow implements IField
{
    var get : Void -> Bool;

    var set : Bool -> Void;

    var inter : Interactive;

    var bitmap : Bitmap;

    var onTile : Tile;

    var offTile : Tile;

    var value : Bool;

    override public function new(label : String, parent : Object, width : Int, height : Int, get : Void -> Bool, set : Bool -> Void, offsetX : Int = 0, icons : Array<Tile>) 
    {
        super(parent);

        this.get = get;
        this.set = set;

        layout = Stack;
        minWidth = maxWidth = width;
        minHeight = maxHeight = height;

        backgroundTile = Tile.fromColor(EngineConst.INSPECTOR_FIELD_COLOR, width, height);

        var text : Text = new Text(hxd.res.DefaultFont.get(), this);
        text.text = label;
        text.textColor = EngineConst.INSPECTOR_TEXT_COLOR;
        getProperties(text).align(Top, Left);
        getProperties(text).offsetX = 10;
        getProperties(text).offsetY = Std.int((height - text.textHeight) / 2);

        onTile = icons[4];
        onTile.scaleToSize(height * 0.8, height * 0.8);
        offTile = icons[5];
        offTile.scaleToSize(height * 0.8, height * 0.8);
        bitmap = new Bitmap(onTile, this);
        getProperties(bitmap).offsetX = 90 + offsetX;

        inter = new Interactive(width * 0.4, height * 0.8, this);
        inter.backgroundColor = Color.iGREY;
        getProperties(inter).align(Top, Left);
        getProperties(inter).offsetX = 120 + offsetX;
        getProperties(inter).offsetY = Std.int((height - inter.height) / 2);

        inter.onPush = (e) -> 
        {
            inter.backgroundColor = Color.iDARKGREY;
            value = !value;
            set(value);

            bitmap.tile = value ? onTile : offTile;
        }

        inter.onRelease = (e) -> inter.backgroundColor = Color.iGREY;
        inter.onReleaseOutside = (e) -> inter.backgroundColor = Color.iGREY;
    }

    public function updateDisplay()
    {
        value = get();
        bitmap.tile = value ? onTile : offTile;
    }
}

class EnumField<T> extends Flow implements IField
{
    var get : Void -> Int;

    var set : Int -> Void;

    var dd : Dropdown;

    var index : Int;

    override public function new(label : String, parent : Object, width : Int, height : Int, get : Void -> Int, set : Int -> Void, e : Enum<T>, icons : Array<Tile>) 
    {
        super(parent);

        this.get = get;
        this.set = set;

        layout = Stack;

        minWidth = maxWidth = width;
        minHeight = maxHeight = height;

        backgroundTile = Tile.fromColor(EngineConst.INSPECTOR_FIELD_COLOR, width, height);

        var text : Text = new Text(hxd.res.DefaultFont.get(), this);
        text.text = label;
        text.textColor = EngineConst.INSPECTOR_TEXT_COLOR;
        getProperties(text).align(Top, Left);
        getProperties(text).offsetX = 10;
        getProperties(text).offsetY = Std.int((height - text.textHeight) / 2);

        var h : Int = Std.int(height * 0.8);
        var enumArray : Array<T> = haxe.EnumTools.createAll(e);
        dd = new Dropdown(this, Std.int(width * 0.6), h, Std.int(h * (enumArray.length + 1)));
        getProperties(dd).align(Top, Left);
        getProperties(dd).offsetX = 90;
        
        for(value in enumArray)
        {
            var t : Text = new Text(hxd.res.DefaultFont.get(), dd);
            t.scale(1.01);
            t.textColor = EngineConst.INSPECTOR_TEXT_COLOR;
            t.text = Std.string(value);
            dd.addItem(t);
        }

        dd.arrowClose = icons[3];
        dd.arrowOpen = icons[3];

        dd.onOpen = () ->
        {
            @:privateAccess dd.arrow.rotation = -AMath.PI / 2;
            dd.getProperties(@:privateAccess dd.arrow).offsetY = 16;
        }

        dd.onClose = () ->
        {
            index = dd.selectedItem;
            set(index);

            @:privateAccess dd.arrow.rotation = 0;
            dd.getProperties(@:privateAccess dd.arrow).offsetY = 0;
        }
    }

    public function updateDisplay()
    {
        index = get();
        dd.selectedItem = index;
    }
}

class DdItem extends Bitmap
{
    override public function new(label : String, parent : Object, width : Int, height : Int) 
    {
        super(Tile.fromColor(EngineConst.INSPECTOR_FOLD_COLOR, width, height), parent);

        var text : Text = new Text(hxd.res.DefaultFont.get(), this);
        text.text = label;
        text.textColor = EngineConst.INSPECTOR_TEXT_COLOR;
    }
}

class InspectorButton extends Bitmap
{
    public var interactive : Interactive;

    public var value (default, set) : Bool;

    var onTile : Tile;

    var offTile : Tile;

    var onColor : Int;

    var offColor : Int;

    var onChange : Bool -> Void;

    override public function new(parent : Object, onTile : Tile, offTile : Tile, onColor : Int, offColor : Int, cb : Bool -> Void) 
    {
        super(onTile, parent);

        this.onTile = onTile;
        this.offTile = offTile;
        this.onColor = onColor;
        this.offColor = offColor;
        onChange = cb;

        interactive = new Interactive(onTile.width, onTile.height, this);
        interactive.onPush = (e) -> value = !value;
        
        value = false;
    }

    function set_value(v : Bool) : Bool
    {
        value = v;

        tile = value ? onTile : offTile;
        color = Color.intToVector(value ? onColor : offColor);

        onChange(value);

        return value;
    }
}

interface IField 
{
    function updateDisplay() : Void;
}