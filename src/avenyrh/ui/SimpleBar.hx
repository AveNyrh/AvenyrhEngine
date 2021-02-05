package avenyrh.ui;

import h2d.Tile;
import h2d.Object;

class SimpleBar extends ProgressBar
{
    var fillDirection : FillDirection;

    public function new(parent : Object, width : Float = 1, height : Float = 1, color : Int = Color.iBLACK, ?tile : Tile, fillDirection : FillDirection = Horizontal) 
    {
        super(parent, width, height, color, tile);

        this.fillDirection = fillDirection;
    }

    override function drawGraph() 
    {
        super.drawGraph();

        graph.clear();

        if(tile != null)
        {
            graph.beginTileFill(0, 0, 1, 1, tile);

            var w = fillDirection == Horizontal ? tile.width * fillAmount : 1;
            var h = fillDirection == Vertical ? tile.height * fillAmount : 1;

            graph.drawRect(0, 0, w, h);
        }
        else
        {
            graph.beginFill(color);

            var w = fillDirection == Horizontal ? width * fillAmount : width;
            var h = fillDirection == Vertical ? height * fillAmount : height;

            graph.drawRect(0, 0, w, h);
        }

        graph.endFill();
    }
}

enum FillDirection
{
    Horizontal;
    Vertical;
}