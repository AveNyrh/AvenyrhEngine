package avenyrh.ui;

import avenyrh.engine.Tweeny;
import h2d.Flow;
import h2d.Tile;
import h2d.Object;
import avenyrh.utils.Tween;
import h2d.Graphics;

/**
 * Base abstract class for all kind of progress bars
 */
class ProgressBar extends Flow
{
    /**
     * Graphics to draw on
     */
    var graph : Graphics;
    /**
     * Tile used by graph
     */
    var tile : Null<Tile>;
    /**
     * Color of the graph tile
     */
    var color : Int;
    /**
     * Ease the fill bar or not
     */
    public var useTween (default, set) : Bool;
    /**
     * Tween used
     */
    var t : Null<Tween>;
    /**
     * Time of the easing
     */
    public var tweenTime : Float;
    /**
     * Type of easing
     */
    var tweenType : TweenType;
    /**
     * Callback for the end of the easing
     */
    var onEndTween : Null<Float -> Void>;
    /**
     * Width of the bar
     */
    var width : Float;
    /**
     * Height of the bar
     */
    var height : Float;
    /**
     * Current amount value
     */
    public var fillAmount (default, null) : Float;

    public function new(parent : Object, width : Float = 1, height : Float = 1, color : Int = Color.iBLACK, ?tile : Tile) 
    {
        super(parent);

        graph = new Graphics(this);

        this.tile = tile;
        this.color = color;
        this.width = width;
        this.height = height;

        fillAmount = 1;

        drawGraph();
    }

    //-------------------------------
    //#region Public API
    //-------------------------------
    /**
     * Eases the bar fill
     */
    public function tween(time : Float, type : TweenType = Linear)
    {
        useTween = true;
        tweenTime = time;
        tweenType = type;

        t = new Tween(1, 1, tweenTime, tweenType);
        t.onUpdate = updateValue;
        t.onEnd = endUpdateValue;
    }

    /**
     * Sets fill value
     */
    public function setFillAmount(value : Float)
    {
        value = AMath.fclamp01(value);

        if(useTween)
        {
            t.from = fillAmount;
            t.to = value;
            t.maxTime = tweenTime;
            t.start();
        }
        else
        {
            fillAmount = value;
        }
        
        drawGraph();
    }
    //#endregion

    //-------------------------------
    //#region Private API
    //-------------------------------
    function updateValue(value : Float) 
    {
        fillAmount = value;

        drawGraph();
    }

    function endUpdateValue() 
    {
        drawGraph();

        if(onEndTween != null)
            onEndTween(fillAmount);
    }

    override function onRemove() 
    {
        super.onRemove();

        if(t != null)
            Tweeny.unregister(t);
    }
    //#endregion

    //-------------------------------
    //#region Overridable functions
    //-------------------------------
    /**
     * Override this to implement how to draw the graph
     */
    function drawGraph() { }
    //#endregion

    //-------------------------------
    //#region Getters & Setters
    //-------------------------------
    function set_useTween(value : Bool) : Bool 
    {
        useTween = value;

        if(useTween && t == null)
            t = new Tween(1, 1);

        return useTween;
    }
    //#endregion
}