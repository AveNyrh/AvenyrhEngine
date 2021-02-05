package avenyrh.ui;

import h2d.Tile;
import h2d.Bitmap;
import h2d.Object;
import h2d.Flow;

class Dropdown extends Flow
{
    var items : Array<Object>;

    var display : DisplayedItem;

    var arrow : Bitmap;

    var highlight : Bitmap;

    var itemsArea : ScrollArea;
    
    public var tileOverItem (default, set) : Tile;

    public var arrowClose (default, set) : Tile;

    public var arrowOpen (default, set) : Tile;

    public var selectedItem (default, set) : Int = -1;

    public var highlightedItem (default, null) : Int = -1;

    public var enable : Bool;

    public function new(parent : Object, width : Int, height : Int)
    {
        super(parent);

        items = [];
        enable = true;

        var pad = 5;
        layout = Stack;
        maxWidth = width +  2 * pad;
        minWidth = width + 2 * pad;

        //Displayed item
        display = new DisplayedItem(this);
        getProperties(display).align(Top, Left);
        getProperties(display).offsetX = pad;

        //Scroll list
        itemsArea = new ScrollArea(this, width + 2 * pad, height * 4);
        getProperties(itemsArea).align(Bottom, Left);
        getProperties(itemsArea).offsetY = height;
        itemsArea.setContentLayout(Vertical);
        itemsArea.allowHorizontal = false;
        itemsArea.paddingLeft = pad;
        itemsArea.visible = false;
        itemsArea.onWheel = onMoveItemArea;

        //Highlight in the scroll list
        tileOverItem = Tile.fromColor(Color.iLIGHTGREY);
        highlight = new Bitmap(tileOverItem, itemsArea);
        highlight.alpha = 0.4;
        itemsArea.getProperties(highlight).isAbsolute = true;

        //Arrow
        arrowClose = Tile.fromColor(Color.iWHITE, height, height);
        arrowOpen = Tile.fromColor(Color.iLIGHTGREY, height, height);
        arrow = new Bitmap(arrowClose, this);
        arrow.width = height;
        arrow.height = height;
        getProperties(arrow).align(Top, Right);

        //Interactives
        enableInteractive = true;
        interactive.onPush = onPush;
        interactive.onClick = onClick;
        //interactive.onFocusLost = onFocusLost;
        interactive.propagateEvents = true;
        itemsArea.enableInteractive = true;
        itemsArea.interactive.onClick = onClickItemArea;
        itemsArea.interactive.onMove = onMoveItemArea;
        itemsArea.interactive.onOut = onOutItemArea;

        //Background
        backgroundTile = Tile.fromColor(Color.iDARKGREY);
        borderWidth = 1;
        borderHeight = 1;

        needReflow = true;
    }

    //--------------------
    //Public API
    //--------------------
    /**
     * Adds an item to the dropdown list \
     * The item can be different from other items in the list
     */
    public function addItem(item : Object)
    {
        items.push(item);

        itemsArea.addToContent(item);

        //Resize
        var width = Std.int(itemsArea.getSize().width);

        if(maxWidth != null && width > maxWidth) 
            width = maxWidth;

        minWidth = AMath.imax(minWidth, Std.int(width-arrow.getSize().width));
    }

    //--------------------
    //Overridable functions
    //--------------------
    /**
	 * Called when the dropdown opens
	 */
    public dynamic function onOpen() { }

    /**
	 * Called when the dropdown closes
	 */
    public dynamic function onClose() { }

	/**
	 * Called when the mouse hovers over an item in the dropdown list
	 */
	public dynamic function onOverItem(item : Object) {	}

	/**
	 * Called when the mouse goes away from an item in the dropdown list
	 */
    public dynamic function onOutItem(item : Object) { }

    //--------------------
    //Private API
    //--------------------
    function onPush(e : hxd.Event)
    {
        if(e.button == 0 && enable)
            interactive.focus();
    }

    function onClick(e : hxd.Event)
    {
        if(itemsArea.visible == true)
        {
            close();
        }
        else if(enable)
        {
            open();
        }
    }

    function onFocusLost(e : hxd.Event)
    {
        if(highlightedItem >= 0 && enable)
            selectedItem = highlightedItem;

        close();
    }

    function onClickItemArea(e : hxd.Event)
    {
        if(highlightedItem >= 0 && enable)
            selectedItem = highlightedItem;

        close();
    }

    function onMoveItemArea(e : hxd.Event)
    {
        if(itemsArea.isScrolling)
            return;

        var mousePos = itemsArea.localToGlobal(new h2d.col.Point(e.relX, e.relY));

        for(i in 0 ... items.length)
        {
            var item = items[i];
            var bds = item.getBounds();

            //If mouse over that item
            if(mousePos.y >= bds.yMin && mousePos.y < bds.yMax && mousePos.x < itemsArea.getSize().width - @:privateAccess itemsArea.vBar.getSize().width + bds.xMin)
            {
                //Mouse over a new item
                if(highlightedItem != i)
                {
                    if(highlightedItem >= 0)
                        onOutItem(items[highlightedItem]);

                    highlightedItem = i;

                    //Highlight the new item
                    highlight.visible = true;
                    var scrollY = @:privateAccess itemsArea.mask.scrollY;
                    highlight.y = item.y - scrollY;
                    highlight.x = itemsArea.paddingLeft;
                    highlight.tile.scaleToSize(item.getSize().width, Std.int(item.getSize().height));

                    onOverItem(item);
                }

                break;
            }
        }
    }

    function onOutItemArea(e : hxd.Event)
    {
        onOutItem(items[highlightedItem]);
        highlightedItem = -1;
        highlight.visible = false;
    }

    function open()
    {
        itemsArea.visible = true;
        arrow.tile = arrowOpen;
        onOpen();
    }

    function close()
    {
        itemsArea.visible = false;
        arrow.tile = arrowClose;
        onClose();
    }

    override function onRemove() 
    {
        super.onRemove();
        
		itemsArea.remove();
	}
    
    //--------------------
    //Getters & Setters
    //--------------------
    override function set_backgroundTile(t : Tile) : Tile 
    {
        super.set_backgroundTile(t);
        
        itemsArea.backgroundTile = t;
        
		return backgroundTile;
	}

    function set_tileOverItem(t : Tile) : Tile
    {
        tileOverItem = t;

        if(highlight != null)
            highlight.tile = t;

        return tileOverItem;
    }

    function set_arrowClose(t : Tile) : Tile
    {
        arrowClose = t;

        if(!itemsArea.visible && arrow != null)
            arrow.tile = arrowClose;

        return arrowClose;
    }

    function set_arrowOpen(t : Tile) : Tile
    {
        arrowOpen = t;

        if(itemsArea.visible && arrow != null)
            arrow.tile = arrowOpen;

        return arrowOpen;
    }

    function set_selectedItem(value : Int) : Int
    {
        selectedItem = value;

        return selectedItem;    
    }
}

private class DisplayedItem extends Object
{
    var dropdown : Dropdown;

    public function new(dd : Dropdown) 
    {
        super(dd);
        
        dropdown = dd;
    }

    override function getBoundsRec(relativeTo : Object, out : h2d.col.Bounds, forSize : Bool) 
    {
        super.getBoundsRec(relativeTo, out, forSize);
        
        if (dropdown.selectedItem >= 0) 
        {
			var item = @:privateAccess dropdown.items[dropdown.selectedItem];
			var size = item.getSize();
			addBounds(relativeTo, out, 0, 0, size.width, size.height);
		}
	}

    override function draw(ctx) 
    {
        if (dropdown.selectedItem >= 0) 
        {
			var item = @:privateAccess dropdown.items[dropdown.selectedItem];
			var oldX = item.absX;
			var oldY = item.absY;
			item.absX = absX;
            item.absY = absY + @:privateAccess dropdown.arrow.height / 2 - this.getSize().height / 2;
			item.drawRec(ctx);
			item.absX = oldX;
            item.absY = oldY;
		}
	}
}