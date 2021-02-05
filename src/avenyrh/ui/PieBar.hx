package avenyrh.ui;

import h2d.Tile;
import h2d.Object;

class PieBar extends ProgressBar
{
    /**
     * Angle at which the cut will appear \
     * Counted clockwise
     */
    var startAngle : Float;
    /**
     * Radius of the pie \
     * Cut the tile to this radius if there is a tile
     */
    var radius : Float;

    public function new(parent : Object, width : Float = 1, height : Float = 1, color : Int = Color.iBLACK, ?tile : Tile, radius : Float, startAngle : Float = 0) 
    {
        super(parent, width, height, color, tile);

        var r : Float = tile != null ? (tile.width >= tile.height ? tile.width / 2 : tile.height / 2) : radius;
        this.radius = r;
        this.startAngle = startAngle;

        drawGraph();
    }

    override function drawGraph() 
    {
        super.drawGraph();

        graph.clear();

        if(tile != null)
        {
            graph.beginTileFill(0, 0, 1, 1, tile);

            graph.drawPie(width / 2, height / 2, radius, startAngle, 2 * AMath.PI * fillAmount);
        }
        else
        {
            graph.beginFill(color);

            graph.drawPie(radius, radius, radius, startAngle, 2 * AMath.PI * fillAmount);
        }
        graph.endFill();
    }
}