package avenyrh.ui;

import h2d.Text.Align;
import hxd.Event;
import h2d.Bitmap;
import h2d.Interactive;
import h2d.Tile;
import h2d.Object;
import h2d.Mask;
import h2d.Flow;

class ScrollArea extends Flow
{
    /**
     * Mask the hides the content view
     */
    var mask : Mask;
    /**
     * Flow for the content
     */
    var maskFlow : Flow;
    /**
     * Horizontal bar containter
     */
    var hBar : Null<Flow>;
    /**
     * Vertical bar containter
     */
    var vBar : Null<Flow>;
    /**
     * Horizontal handle
     */
    var hHandle : Null<Interactive>;
    /**
     * Vertical handle
     */
    var vHandle : Null<Interactive>;
    /**
     * Allow horizontal scrolling
     */
    public var allowHorizontal (default, set) : Bool = true;
    /**
     * Allow vertical scrolling
     */
    public var allowVertical (default, set) : Bool = true;
    /**
     * True when the handle is dragged
     */
    public var isScrolling (default, null) : Bool;
    /**
     * Speed for the wheel scroll
     */
    public var wheelSpeed : Float = 4;

    public function new(parent : Object, width : Int, height : Int) 
    {
        super(parent);

        minWidth = width;
        minHeight = height;
        maxWidth = width;
        maxHeight = height;

        layout = Stack;

        mask = new Mask(width, height, this);
        getProperties(mask).align(Top, Left);

        maskFlow = new Flow(mask);

        updateHandles();

        enableInteractive = true;
        interactive.onWheel = onWheelUpdate;
    }

    //-------------------------------
    //#region Public API
    //-------------------------------
    /**
     * Adds something to the content view
     */
    public function addToContent(object : Object) 
    {
        maskFlow.addChild(object);

        updateHandles();
    }

    /**
     * Sets the width of the scroll area
     */
    public function setWidth(w : Int)
    {
        minWidth = w;
        maxWidth = w;
        mask.width = w;

        updateHandles();
    }
    /**
     * Sets the height of the scroll area
     */
    public function setHeight(h : Int)
    {
        minHeight = h;
        maxHeight = h;
        mask.height = h;

        updateHandles();
    }

    /**
     * Sets the layout for the content view \
     * Is different from this layout
     */
    public function setContentLayout(l : FlowLayout)
    {
        maskFlow.layout = l;
    }

    /**
     * Set the align for the content view \
     * Is different from this layout
     */
    public function setContentAlign(horizontal : FlowAlign, vertical : FlowAlign)
    {
        maskFlow.horizontalAlign = horizontal;
        maskFlow.verticalAlign = vertical;
    }
    //#endregion
    
    //-------------------------------
    //#region Overridable functions
    //-------------------------------
    /**
     * Called when the wheel is used to move the scroll area
     */
    public dynamic function onWheel(e : hxd.Event) { }
    //#endregion

    //-------------------------------
    //#region Private API
    //-------------------------------
    function onWheelUpdate(e : hxd.Event) 
    {
        var delta = e.wheelDelta * wheelSpeed;

        if(delta == 0)
            return;

        if(!hxd.Key.isDown(hxd.Key.CTRL) && allowVertical && vBar != null)
        {
            //Calculate the current position in %
            var percent = (vBar.getProperties(vHandle).offsetY + delta) / getVerticalMaxValue();
            percent = AMath.fclamp01(percent);

            //Place at new position
            vBar.getProperties(vHandle).offsetY = AMath.round(percent * getVerticalMaxValue());

            //Scroll
            mask.scrollY = percent * (maskFlow.getSize().height - mask.height);

            needReflow = false;

            onWheel(e);
        }
        else if(allowHorizontal && hBar != null)
        {
            //Calculate the current position in %
            var percent = (hBar.getProperties(hHandle).offsetX + delta) / getHorizontalMaxValue();
            percent = AMath.fclamp01(percent);

            //Place at new position
            hBar.getProperties(hHandle).offsetX = AMath.round(percent * getHorizontalMaxValue());

            //Scroll
            mask.scrollX = percent * (maskFlow.getSize().width - mask.width);

            needReflow = false;

            onWheel(e);
        }
    }

    function updateHandles() 
    {
        if(contentHeightMasked() && vBar == null && allowVertical)
            generateVerticalHandle();
        else if((!contentHeightMasked() && vBar != null) || !allowVertical)
        {
            vBar.remove();
            vBar = null;

            if(vHandle != null)
            {
                vHandle.remove();
                vHandle = null;
            }
        }
        else if(vBar != null)
        {
            //Calculate the current position in %
            var percent = vBar.getProperties(vHandle).offsetY / getVerticalMaxValue();

            //Set new heigh
            vHandle.height = mask.height * mask.height / maskFlow.getSize().height;

            //Place at new position
            vBar.getProperties(vHandle).offsetY = AMath.round(percent * getVerticalMaxValue());

            //Scroll
            mask.scrollY = percent * (maskFlow.getSize().height - mask.height);
        }

        if(contentWhidthMasked() && hBar == null && allowHorizontal)
            generateHorizontalHandle();
        else if((!contentWhidthMasked() && hBar != null) || !allowHorizontal)
        {
            hBar.remove();
            hBar = null;

            if(hHandle != null)
            {
                hHandle.remove();
                hHandle = null;
            }
        }
        else if(hHandle != null)
        {
            //Calculate the current position in %
            var percent = hBar.getProperties(hHandle).offsetX / getHorizontalMaxValue();

            //Set new width
            hHandle.width = mask.width * mask.width / maskFlow.getSize().width;

            //Place at new position
            hBar.getProperties(hHandle).offsetX = AMath.round(percent * getHorizontalMaxValue());

            //Scroll
            mask.scrollX = percent * (maskFlow.getSize().width - mask.width);
        }

        needReflow = true;
    }

    function generateHorizontalHandle() 
    {
        //Bar
        hBar = new Flow(this);
        hBar.layout = Stack;
        getProperties(hBar).verticalAlign = Bottom;

        var w : Int = mask.width;
        var h : Int = 20;

        //Background
        var bg : Bitmap = new Bitmap(Tile.fromColor(Color.iDARKGREY, w, h), hBar);
        hBar.getProperties(bg).align(Bottom, Left);

        //Handle
        hHandle = new h2d.Interactive(w * mask.width / maskFlow.getSize().width, h, hBar);
        hBar.getProperties(hHandle).align(Bottom, Left);
        hHandle.backgroundColor = Color.iLIGHTGREY;

        hHandle.onPush = function(e : Event)
        {
            var oPos : Float = e.relX;

            hHandle.startDrag(function (ev : Event) 
            {
                //Stop grabbing when released
                if(ev.kind == ERelease) 
                {
                    isScrolling = false;
                    hHandle.stopDrag();
					return;
                }

                isScrolling = true;

                //Calculate new position
                var xPos : Float = hBar.getProperties(hHandle).offsetX + ev.relX - oPos;

                //Clamp value so that the handle stays in the bar
                hBar.getProperties(hHandle).offsetX = AMath.round(AMath.fclamp(xPos, 0, getHorizontalMaxValue()));

                //Scroll
                var percent = hBar.getProperties(hHandle).offsetX / getHorizontalMaxValue();
                var w : Float = vHandle != null ? vHandle.width : 0;
                mask.scrollX = percent * (maskFlow.getSize().width - mask.width + w);

                //Don't reflow, it causes this flow to jitter
                needReflow = false;
            });
        };
    }

    inline function getHorizontalMaxValue() : Int
    {
        var w : Float = vHandle != null ? vHandle.width : 0;
        return AMath.round(mask.width - hHandle.width - w);
    }
    
    function generateVerticalHandle() 
    {
        //Bar
        vBar = new Flow(this);
        vBar.layout = Stack;
        getProperties(vBar).horizontalAlign = Right;

        var w : Int = 20;
        var h : Int = mask.height;

        //Background
        var bg : Bitmap = new Bitmap(Tile.fromColor(Color.iDARKGREY, w, h), vBar);
        vBar.getProperties(bg).align(Top, Right);

        //Handle
        vHandle = new h2d.Interactive(w, h * mask.height / maskFlow.getSize().height, vBar);
        vBar.getProperties(vHandle).align(Top, Right);
        vHandle.backgroundColor = Color.iLIGHTGREY;

        vHandle.onPush = function(e : Event)
        {
            var oPos : Float = e.relY;

            vHandle.startDrag(function (ev : Event) 
            {
                //Stop grabbing when released
                if(ev.kind == ERelease) 
                {
                    isScrolling = false;
                    vHandle.stopDrag();
					return;
                }

                isScrolling = true;

                //Calculate new position
                var yPos : Float = vBar.getProperties(vHandle).offsetY + ev.relY - oPos;

                //Clamp value so that the handle stays in the bar
                vBar.getProperties(vHandle).offsetY = AMath.round(AMath.fclamp(yPos, 0, getVerticalMaxValue()));

                //Scroll
                var percent = vBar.getProperties(vHandle).offsetY / getVerticalMaxValue();
                var h : Float = hHandle != null ? hHandle.height : 0;
                mask.scrollY = percent * (maskFlow.getSize().height - mask.height + h);
                
                //Don't reflow, it causes this flow to jitter
                needReflow = false;
            });
        };
    }

    inline function getVerticalMaxValue() : Int
    {
        var h : Float = hHandle != null ? hHandle.height : 0;
        return AMath.round(mask.height - vHandle.height - h);
    }

    /**
     * True if the content is wider than the scroll area
     */
    inline function contentWhidthMasked() : Bool
    {
        return maskFlow.getSize().width > mask.width;
    }

    /**
     * True if the content is higher than the scroll area
     */
    inline function contentHeightMasked() : Bool
    {
        return maskFlow.getSize().height > mask.height;
    }
    //#endregion

    //-------------------------------
    //#region Getters & Setters
    //-------------------------------
    function set_allowHorizontal(value : Bool) : Bool
    {
        allowHorizontal = value;

        updateHandles();

        return allowHorizontal;
    }

    function set_allowVertical(value : Bool) : Bool
    {
        allowVertical = value;

        updateHandles();

        return allowVertical;
    }
    //#endregion
}