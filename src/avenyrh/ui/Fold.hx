package avenyrh.ui;

import avenyrh.engine.EngineConst;
import h2d.col.Bounds;
import h2d.Tile;
import h2d.Flow;
import h2d.Font;
import h2d.Bitmap;
import h2d.Text;
import h2d.Object;

class Fold extends Flow 
{
    public var label : Text;

    public var labelBg : Bitmap;

    public var arrow : Bitmap;

    public var container : Object;

    public var isOpen (default, set) : Bool;

    public var onChange : Null<Bool -> Void>;

    override public function new(parent : Null<Object>, text : String, font : Font, labelWidth : Int, labelHeight : Int, labelBgColor : Int) 
    {
        super(parent);

        layout = Stack;
        minWidth = labelWidth;
        minHeight = labelHeight;

        labelBg = new Bitmap(Tile.fromColor(labelBgColor, labelWidth, labelHeight), this);
        getProperties(labelBg).align(Top, Left);

        label = new Text(font, this);
        label.text = text;
        getProperties(label).align(Top, Left);
        getProperties(label).offsetX = 10;
        getProperties(label).offsetY = Std.int((labelHeight - label.textHeight) / 2);

        var icons : Array<Tile> = hxd.res.Embed.getResource("avenyrh/engine/icons.png").toTile().split(6);
        var t : Tile = icons[3];
        t.scaleToSize(labelHeight * 0.4, labelHeight * 0.4);
        t.dx = -t.width / 2;
        t.dy = -t.height / 2;
        arrow = new Bitmap(t, this);
        getProperties(arrow).align(Top, Right);
        getProperties(arrow).offsetX = Std.int(- t.width * 0.5);
        getProperties(arrow).offsetY = Std.int((labelHeight - arrow.height) / 2);
        arrow.rotation = -AMath.PI / 2;

        container = new Object(this);
        getProperties(container).align(Top, Left);
        getProperties(container).offsetY = labelHeight;

        enableInteractive = true;
        interactive.height = labelHeight;
        interactive.onPush = (e) -> isOpen = !isOpen;

        isOpen = true;
    }

    function set_isOpen(value : Bool) : Bool
    {
        isOpen = value;

        container.visible = value;

        arrow.rotation = isOpen ? -AMath.PI / 2 : 0;

        if(onChange != null)
            onChange(isOpen);

        return isOpen;
    }

    override function reflow() 
    {
        super.reflow();

        if(interactive != null)
            interactive.height = minHeight;
    }

    override function getBoundsRec(relativeTo : Object, out : Bounds, forSize : Bool)
    {
        super.getBoundsRec(relativeTo, out, forSize);

        if(forSize)
        {
            var bds : Bounds = out;
            bds.height += isOpen ? minHeight : 0;
        }
    }
}