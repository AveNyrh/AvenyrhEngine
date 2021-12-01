package avenyrh;

import h2d.Tile;

class Sprite
{
    public var filePath (default, set) : String;
    
    public var x (get, set) : Null<Float>;
    
    public var y (get, set) : Null<Float>;
    
    public var width (get, set) : Null<Float>;
    
    public var height (get, set) : Null<Float>;

    public var tile (default, set) : Tile;

    public function new(?filepath : String, ?x : Float, ?y : Float, ?w : Float, ?h : Float)
    {
        if(filepath != null && filepath != "")
            this.filePath = filepath;
        
        if(x != null)
            this.x = x;

        if(y != null)
            this.y = y;

        if(w != null)
            this.width = w;

        if(h != null)
            this.height = h;

        setTile();
    }

    public function toString() : String
    {
        return 'Sprite : $filePath | x = $x | y = $y | width = $width | height = $height';
    }

    //-------------------------------
    //#region Private API
    //-------------------------------
    /**
     * Ensure that tile is never null
     */
    inline function setTile()
    {
        if(tile == null)
            tile = Tile.fromColor(Color.iWHITE, 10, 10, 1);
    }
    //#endregion

    //-------------------------------
    //#region Getters & Setters
    //-------------------------------
    function set_filePath(path : String) : String
    {
        var t : Tile = hxd.Res.load(path).toTile();
        tile = t;

        var x : Float = this.x == null ? t.x : this.x;
        var y : Float = this.y == null ? t.y : this.y;
        var w : Float = this.width == null ? t.width : this.width;
        var h : Float = this.height == null ? t.height : this.height;

        tile.setPosition(x, y);
        tile.setSize(w, h);

        return filePath = path;
    }

    function get_x() : Float
    {
        setTile();
        return tile.x;
    }

    function set_x(x : Float) : Float
    {
        setTile();
        tile.setPosition(x, tile.y);
        return tile.x;
    }

    function get_y() : Float
    {
        setTile();
        return tile.y;
    }

    function set_y(y : Float) : Float
    {
        setTile();
        tile.setPosition(tile.x, y);
        return tile.y;
    }

    function get_width() : Float
    {
        setTile();
        return tile.width;
    }

    function set_width(w : Float) : Float
    {
        setTile();
        tile.setSize(w, tile.height);
        return tile.width;
    }

    function get_height() : Float
    {
        setTile();
        return tile.height;
    }

    function set_height(h : Float) : Float
    {
        setTile();
        tile.setSize(tile.width, h);
        return tile.height;
    }

    function set_tile(t : Tile) : Tile
    {
        tile = t;
        x = tile.x;
        y = tile.y;
        width = tile.width;
        height = tile.height;

        return tile;
    }
    //#endregion
}