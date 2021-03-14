package avenyrh.ui;

import h2d.Bitmap;
import h2d.Tile;
import h2d.Object;
import h2d.Text;
import h2d.Flow;

class Checkbox extends Flow
{
    /**
     * Text field
     */
    public var txt : Text;
    /**
     * Check image
     */
    var check : Bitmap;
    /**
     * Box image
     */
    var box : Bitmap;
    /**
     * Bow and check container
     */
    var boxContainer : Flow;
    /**
     * Current value of the checkbox
     */
    public var value (default, set) : Bool;
    /**
     * Callback when the value is changed
     */
    public var onValueChange : Null<Bool -> Void>;
    /**
     * If disabled, it can't be interacted with
     */
    public var enable : Bool;

    public function new(parent : Object, width : Int, height : Int, ?text : String, ?check : Tile, ?box : Tile, ?bg : Tile, ?checkColor : Int, ?boxColor : Int, ?bgColor : Int) 
    {
        super(parent);

        padding = Std.int(height * 0.1);
		verticalAlign = Middle;
		horizontalSpacing = 5;

        minWidth = height;
        minHeight = height;
        
        //Background
        if(bg != null)
            backgroundTile = bg;
        else 
        {
            var c : Int = bgColor == null ? Color.iDARKGREY : bgColor;
            backgroundTile = Tile.fromColor(c, width, height);
        }

        boxContainer = new Flow(this);

        //Box
        if(box != null)
            this.box = new Bitmap(box, this);
        else 
        {
            //Box bg
            var size : Int = Std.int(height * 0.8);
            var c : Int = boxColor == null ? Color.iLIGHTGREY : boxColor;
            var t = Tile.fromColor(c, size, size);
            this.box = new Bitmap(t, boxContainer);

            //Box interior
            size = Std.int(height * 0.6);
            c = Color.iDARKGREY;
            t = Tile.fromColor(c, size, size);
            var inter : Bitmap = new Bitmap(t, boxContainer);
            inter.x = height * 0.1;
            inter.y = height * 0.1;
            boxContainer.getProperties(inter).isAbsolute = true;
        }

        //Check
        if(check != null)
        {
            this.check = new Bitmap(check, boxContainer);

            //TO DO : Fix x and y position
            this.check.x = check.width / 2;
            this.check.y = -check.height / 2;
        }
        else 
        {
            var size : Int = Std.int(height * 0.6);
            var c : Int = checkColor == null ? Color.iWHITE : checkColor;
            var t = Tile.fromColor(c, size, size);
            this.check = new Bitmap(t, boxContainer);

            this.check.x = height * 0.1;
            this.check.y = height * 0.1;
        }

        boxContainer.getProperties(this.check).isAbsolute = true;

        //Text
        txt = new Text(hxd.res.DefaultFont.get(), this);
        getProperties(txt).offsetY = -Std.int(height * 0.1);
        if(text != null)
            txt.text = text;

        enableInteractive = true;
		interactive.cursor = Button;
		interactive.onClick = onClick;

		enable = true;
        value = true;
        needReflow = true;
    }

    function onClick(e : hxd.Event) 
    {
        if(enable)
        {
            value = !value;
            
            if(onValueChange != null)
                onValueChange(value);
        }
    }

    function set_value(v : Bool) : Bool
    {
        value = v;
        check.visible = value;

        return value;
    }
}