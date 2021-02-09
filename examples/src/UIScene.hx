package examples.src;

import avenyrh.InputManager;
import examples.src.pathfinding.PFScene;
import avenyrh.engine.Engine;
import avenyrh.ui.Dropdown;
import avenyrh.ui.ScrollArea;
import h2d.Mask;
import h2d.Text;
import h2d.Slider;
import avenyrh.ui.PieBar;
import avenyrh.ui.SimpleBar;
import h2d.TextInput;
import h2d.Bitmap;
import h2d.Tile;
import h2d.Graphics;
import avenyrh.ui.TabButton;
import avenyrh.ui.TabGroup;
import avenyrh.AMath;
import avenyrh.utils.Tween;
import h2d.Flow;
import avenyrh.ui.Checkbox;
import avenyrh.Color;
import avenyrh.ui.Button;
import avenyrh.engine.Scene;
import avenyrh.engine.Process;

class UIScene extends Scene
{
    var button : Button;
    var button2 : Button;

    var tab : TabGroup;

    var ti : TextInput;

    var g : Graphics;

    var sbar : SimpleBar;
    var pbar : PieBar;

    var mask : Mask;
    var scroll : ScrollArea;

    var dropdown : Dropdown;

    public override function new() 
    {
        super("TestScene");
    }

    override function added() 
    {
        super.added();

        ui.horizontalSpacing = 10;
        ui.verticalSpacing = 10;
        ui.padding = 10;

        // spawnButton();
        // spawnCheckbox();
        // spawnTab();
        // spawnTextInput();
        // spawnSimpleBar(ui);
        // spawnPieBar(ui);
        // spawnScrollArea(ui);
        // spawnDropdown(ui);

        fullExample();
    }

    function spawnButton() 
    {
        button = new Button(ui, 100, 60);
        button.setText("Button test", Color.BLACK);
        button.onClick = onClick;

        button2 = new Button(ui, 100, 60);
        button2.setText("Button test 2", Color.BLACK);
        button2.idle.customTile = hxd.Res.CarreBlanc.toTile();
        button2.idle.customTile.scaleToSize(button2.width, button2.height);
        button2.hover.customTile = hxd.Res.CarreVert.toTile();
        button2.hover.customTile.scaleToSize(button2.width, button2.height);
        button2.press.customTile = hxd.Res.CarreRouge.toTile();
        button2.press.customTile.scaleToSize(button2.width, button2.height);
        button2.useColor = false;
        button2.onClick = onClick2;
    }

    function onClick(e : hxd.Event)
    {
        button2.interactable = !button2.interactable;
    }

    function onClick2(e : hxd.Event)
    {
        trace("On click 2");
    }

    function spawnCheckbox() 
    {
        var flow = new Flow(ui);
        flow.layout = Vertical;

        var c : Checkbox;
        var t : Tween;
        for (i in 0...8)
        {
            if(AMath.isEven(i))
                c = new Checkbox(flow, 140, 40, 'Checkbox $i');
            else 
                c = new Checkbox(flow, 140, 40, 'Checkbox $i', hxd.Res.CarreVert.toTile(), hxd.Res.CarreBlanc.toTile(), hxd.Res.CarreBleu.toTile());
            t = new Tween(-200, 0, 0.4 / (0.1 * i), LittleJump).setOnUpdate(function (x : Float) { flow.getProperties(c).offsetX = Std.int(x); }).start();
        }
    }

    function spawnTab(flowParent : Flow) 
    {
        var f : Flow = new Flow(flowParent);
        f.layout = Horizontal;
        f.horizontalSpacing = 10;
        tab = new TabGroup(f);
        tab.layout = Vertical;
        tab.verticalSpacing = 10;
        var fb : Flow = new Flow(f);

        var tb : TabButton;
        var b : Bitmap;
        for (i in 0 ... 6)
        {
            tb = new TabButton(60,60, tab);
            tb.idle.color = getColor(i);
            b = new Bitmap(Tile.fromColor(getColor(i), 410, 410), fb);

            tab.addButton(tb, b);
        }
    }

    function getColor(i : Int) : Int 
    {
        switch (i)
        {
            case 1 : return Color.iBEIGE;
            case 2 : return Color.iBLACK;
            case 3 : return Color.iBLUE;
            case 4 : return Color.iBROWN;
            case 5 : return Color.iCYAN;
            case 6 : return Color.iGREEN;
            default : return Color.iWHITE;
        }
    }

    function spawnTextInput() 
    {
        ti = new h2d.TextInput(hxd.res.DefaultFont.get(), ui);
        ti.backgroundColor = Color.iBLACK;
    
        ti.text = "Click to édit";
        ti.textColor = Color.iLIGHTGREY;
    
        ti.scale(2);
        ti.x = ti.y = 50;
    
        ti.onFocus = function(_) 
        {
            ti.textColor = Color.iWHITE;
        }

        ti.onFocusLost = function(_) 
        {
            ti.textColor = Color.iLIGHTGREY;
        }
    }

    function spawnSimpleBar(flowParent : Flow) 
    {
        sbar = new SimpleBar(flowParent, 200, 40, Color.iGREEN);
        sbar.tween(0.8, EaseOut);

        var slider = new Slider(100, 20, flowParent);
        slider.onChange = function() { sbar.setFillAmount(slider.value); };
        slider.value = 1;
        
        button = new Button(flowParent, 100, 60);
        button.setText("Set to 0", Color.BLACK);
        button.onClick = function(_) 
        { 
            sbar.setFillAmount(0); 
            slider.value = 0;
        };

        button2 = new Button(flowParent, 100, 60);
        button2.setText("Set to 1", Color.BLACK);
        button2.onClick = function(_) 
        { 
            sbar.setFillAmount(1);
            slider.value = 1;
        };

        var c = new Checkbox(flowParent, 60, 60, "Use tween");
        c.onValueChange = function(v) { sbar.useTween = v; };
    }

    function spawnPieBar(flowParent : Flow) 
    {
        var t : Tile = hxd.Res.Coin.toTile();
        pbar = new PieBar(flowParent, t.width, t.height, Color.iBROWN, t, 1, - AMath.PI / 2);
        pbar.scale(200 / t.width);

        var slider = new Slider(100, 20, flowParent);
        slider.onChange = function() { pbar.setFillAmount(slider.value); };
        slider.value = 1;
    }

    function spawnScrollArea(flowParent : Flow) 
    {
        scroll = new ScrollArea(flowParent, 200, 200);
        var b : Bitmap = new Bitmap(hxd.Res.Coin.toTile());
        scroll.addToContent(b);

        var button : Button = new Button(flowParent, 200, 60);
        button.onClick = function(_) { scroll.allowHorizontal = !scroll.allowHorizontal; };
        button.setText("Allow horizontal");

        button = new Button(flowParent, 200, 60);
        button.onClick = function(_) { scroll.allowVertical = !scroll.allowVertical; };
        button.setText("Allow vertical");
    }

    function spawnDropdown(flowParent : Flow)
    {
       dropdown = new Dropdown(flowParent, 200, 60);
        
        var f : Flow;
        var t : Text;
        var b : Bitmap;

        for(i in 0...10)
        {
            b = new Bitmap(Tile.fromColor(Std.int(Math.random() * Color.iBLACK), 140, 40), dropdown);

            dropdown.addItem(b);
        }

        dropdown.selectedItem = 0;
    }

    function fullExample()
    {
        ui.layout = Vertical;

        var f : Flow = new Flow(ui);
        f.horizontalSpacing = 10;
        f.verticalSpacing = 10;
        f.padding = 10;
        spawnSimpleBar(f);
        f = new Flow(ui);
        f.horizontalSpacing = 10;
        f.verticalSpacing = 10;
        f.padding = 10;
        spawnPieBar(f);
        f = new Flow(ui);
        f.horizontalSpacing = 10;
        f.verticalSpacing = 10;
        f.padding = 10;
        spawnScrollArea(f);
        f = new Flow(ui);
        f.layout = Horizontal;
        f.horizontalSpacing = 10;
        f.verticalSpacing = 10;
        f.padding = 10;
        spawnTab(f);
        spawnDropdown(f);
       f.getProperties(dropdown).align(Top, Right);
    }

    override function update(dt:Float) 
    {
        super.update(dt);

        if(hxd.Key.isPressed(hxd.Key.RIGHT))
        {
            Engine.instance.addScene(new PFScene());
        }
        else if(hxd.Key.isPressed(hxd.Key.LEFT))
        {
            Engine.instance.addScene(new GameObjectScene());
        }
    }
}