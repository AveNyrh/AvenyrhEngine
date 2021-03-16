package avenyrh.ui;

import h2d.RenderContext;
import hxd.Event;
import h2d.col.Collider;

@:allow(TabGroup)
class TabButton extends Button
{
    var tabGroup : TabGroup;

    var isSelected : Bool;

    public function new(width : Float, height : Float, tabGroup : TabGroup, ?shape : Collider) 
    {
        super(tabGroup.buttonsFlow, width, height, shape);

        this.tabGroup = tabGroup;
        isSelected = false;
    }

    override function onClick(e : Event) 
    {
        @:privateAccess tabGroup.onTabSelected(this);
    }

    override function draw(ctx:RenderContext) 
    {
        if(isSelected)
            emitTile(ctx, useColor ? hover.tile : hover.customTile);
        else
            super.draw(ctx);
    }
}