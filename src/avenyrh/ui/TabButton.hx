package avenyrh.ui;

import hxd.Event;
import h2d.col.Collider;

class TabButton extends Button
{
    var tabGroup : TabGroup;

    public function new(width : Float, height : Float, tabGroup : TabGroup, ?shape : Collider) 
    {
        super(tabGroup.buttonsFlow, width, height, shape);

        this.tabGroup = tabGroup;
    }

    override function onClick(e : Event) 
    {
        @:privateAccess tabGroup.onTabSelected(this);
    }
}