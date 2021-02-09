package avenyrh.ui;

import h2d.Bitmap;
import h2d.Tile;
import h2d.Object;
import h2d.Flow;

class NineSlice extends Flow
{
    var topLeftCorner : Bitmap;

    var topMiddleCenter : Bitmap;

    var topRightCorner : Bitmap;

    var middleLeftCenter : Bitmap;

    var middleMiddleCenter : Bitmap;

    var middleRightCenter : Bitmap;

    var bottomLeftCorner : Bitmap;

    var bottomMiddleCenter : Bitmap;

    var bottomRightCorner : Bitmap;

    var bWidth : Float;

    var bHeight : Float;

    /**
     * Center of the 9-slice tile\
     * Where to add the content if needed
     */
    public var content (default, null) : Flow;

    override public function new(?parent : Object, tile : Tile, borderWidth : Float, borderHeight : Float) 
    {
        super(parent);

        layout = Stack;

        minWidth = Std.int(tile.width);
        minHeight = Std.int(tile.height);

        bWidth = borderWidth;
        bHeight = borderHeight;

        var middleWidth : Float = tile.width - 2 * borderWidth;
        var middleHeight : Float = tile.height - 2 * borderHeight;

        //Create bitmaps
        topLeftCorner = new Bitmap(tile.sub(0, 0, borderWidth, borderHeight), this);
        topMiddleCenter = new Bitmap(tile.sub(borderWidth, 0, middleWidth, borderHeight), this);
        topRightCorner = new Bitmap(tile.sub(borderWidth + middleWidth, 0, borderWidth, borderHeight), this);
        middleLeftCenter = new Bitmap(tile.sub(0, borderHeight, borderWidth, middleHeight), this);
        middleMiddleCenter = new Bitmap(tile.sub(borderWidth, borderHeight, middleWidth, middleHeight), this);
        middleRightCenter = new Bitmap(tile.sub(borderWidth + middleWidth, borderHeight, borderWidth, middleHeight), this);
        bottomLeftCorner = new Bitmap(tile.sub(0, borderHeight + middleHeight, borderWidth, borderHeight), this);
        bottomMiddleCenter = new Bitmap(tile.sub(borderWidth, borderHeight + middleHeight, middleWidth, borderHeight), this);
        bottomRightCorner = new Bitmap(tile.sub(borderWidth + middleWidth, borderHeight + middleHeight, borderWidth, borderHeight), this);

        //Place bitmaps
        getProperties(topLeftCorner).align(Top, Left);
        getProperties(topMiddleCenter).align(Top, Middle);
        getProperties(topRightCorner).align(Top, Right);
        getProperties(middleLeftCenter).align(Middle, Left);
        getProperties(middleMiddleCenter).align(Middle, Middle);
        getProperties(middleRightCenter).align(Middle, Right);
        getProperties(bottomLeftCorner).align(Bottom, Left);
        getProperties(bottomMiddleCenter).align(Bottom, Middle);
        getProperties(bottomRightCorner).align(Bottom, Right);

        //Content
        content = new Flow(this);
        getProperties(content).isAbsolute = true;
        getProperties(content).offsetX = Std.int(borderWidth);
        getProperties(content).offsetY = Std.int(borderHeight);
        content.minWidth = Std.int(middleWidth);
        content.minHeight = Std.int(middleHeight);
        content.onAfterReflow = afterContentReflow;

        needReflow = true;
    }

    function afterContentReflow()
    {
        var bds : h2d.col.Bounds = content.getSize();
        var sX : Float = (bds.width) / 5;
        var sY : Float = (bds.height) / 5;

        topMiddleCenter.scaleX = sX;
        middleLeftCenter.scaleY = sY;
        middleMiddleCenter.scaleX = sX;
        middleMiddleCenter.scaleY = sY;
        middleRightCenter.scaleY = sY;
        bottomMiddleCenter.scaleX = sX;

        minWidth = Std.int(bds.width + 2 * bWidth);
        minHeight = Std.int(bds.height + 2 * bHeight);
        
        content.setPosition(bWidth, bHeight);

        needReflow = true;
    }
}