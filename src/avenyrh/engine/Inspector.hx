package avenyrh.engine;

import avenyrh.imgui.ImGui;
import avenyrh.imgui.ImGuiDrawable;
import h2d.Tile;

class Inspector extends Process
{
    /**
     * Is the inspector running
     */
    var enable : Bool;

    /**
     * Current object being inspected
     */
    public static var currentInspectable : Null<IInspectable>;

    var lock : Bool = false;

    var icons : Array<Tile>;

    var drawable : ImGuiDrawable;

    override public function new() 
    {
        super("Inspector");

        createRoot(Process.S2D, 10);
        drawable = new ImGuiDrawable(root);

        close();
    }

    //-------------------------------
    //#region Private API
    //-------------------------------
    override function update(dt : Float) 
    {
        super.update(dt);

        if(hxd.Key.isPressed(hxd.Key.F4))
            enable ? close() : open();
    }

    override function postUpdate(dt : Float) 
    {
        super.postUpdate(dt);

        if(!enable)
            return;

        draw(dt);
    }

    function draw(dt : Float)
    {
        drawable.update(dt);

        ImGui.newFrame();

        //ImGui.showDemoWindow();

        //Hierarchy window
        ImGui.begin("Hierarchy");

        var scene : Scene = Engine.instance.currentScene;
        var flags : ImGuiTreeNodeFlags = DefaultOpen;

        ImGui.separator();
        if(ImGui.treeNodeEx("Process", flags))
        {
            for(p in scene.children)
            {
                var i : IInspectable = p.drawHierarchy();

                if(i != null)
                {
                    ImGui.spacing();
                    currentInspectable = i;
                    ImGui.spacing();
                }
            }
            ImGui.treePop();
        }

        ImGui.separator();
        if(ImGui.treeNodeEx("UI", flags))
        {
            for(i in 0 ... scene.ui.numChildren)
            {
                if(Std.isOfType(scene.ui.getChildAt(i), IInspectable))
                {
                    ImGui.spacing();
                    var inspec : IInspectable = cast scene.ui.getChildAt(i);
                    var insp : IInspectable = inspec.drawHierarchy();

                    if(insp != null)
                        currentInspectable = insp;

                    ImGui.spacing();
                }
            }
            ImGui.treePop();
        }

        ImGui.separator();
        if(ImGui.treeNodeEx("Game", flags))
        {
            for(i in 0 ... scene.scroller.numChildren)
            {
                if(Std.isOfType(scene.scroller.getChildAt(i), IInspectable))
                {
                    ImGui.spacing();
                    var inspec : IInspectable = cast scene.scroller.getChildAt(i);
                    var insp : IInspectable = inspec.drawHierarchy();

                    if(insp != null)
                        currentInspectable = insp;

                    ImGui.spacing();
                }
            }
            ImGui.treePop();
        }

        ImGui.end();

        //Inspector Window
        ImGui.begin("Inspector");

        if(currentInspectable != null)
        {
            if(ImGui.collapsingHeader('${currentInspectable.name}###${currentInspectable.name}${currentInspectable.uID}', DefaultOpen))
            {
                currentInspectable.drawInspector();
            }
        }

        ImGui.end();
        ImGui.render();
        ImGui.endFrame();
    }
    //#endregion

    //-------------------------------
    //#region Public API
    //-------------------------------
    public function open()
    {
        enable = true;

        drawable.alpha = 1;
    }

    public function close()
    {
        enable = false;

        drawable.alpha = 0;

        currentInspectable = null;
    }
    //#endregion

    //-------------------------------
    //#region Public static API
    //-------------------------------
    /**
     * Returns true if one of the values has changed
     */
    public static function dragFields(label : String, id : Int, data : Array<Any>, step : Float = 1, format : String = "%.3f") : Bool
    {
        var na = new hl.NativeArray<Single>(data.length);
        var changed : Bool = false;

        for(i in 0 ... data.length)
            na[i] = data[i];

        if(ImGui.dragFloat('$label###$label$id', na, step, format))
        {
            changed = true;
            for(i in 0 ... data.length)
                data[i] = na[i];
        }

        return changed;
    }

    /**
     * Returns the index of the selected enum value
     */
    public static function enumDropdown<T>(label : String, id : Int, e : Enum<T>, index : Int, maxItemShown : Int = 4) : Int
    {
        var changed : Bool = false;
        var ea : Array<T> = haxe.EnumTools.createAll(e);
        var na = new hl.NativeArray<String>(ea.length);

        for(i in 0 ... ea.length)
            na[i] = Std.string(ea[i]);

        if(ImGui.beginCombo('$label###$label$id', na[index]))
        {
            for(i in 0 ... na.length)
            {
                var isSelected : Bool = i == index;

                if(ImGui.selectable(na[i], isSelected))
                {
                    index = i;
                    changed = true;
                }
            }

            ImGui.endCombo();
        }

        return index;
    }

    public static function button(label : String, id : Int) : Bool
    {
        return ImGui.button('$label###$label$id', {x : 200, y : 20});
    }

    /**
     * Returns the value of the checkbox
     */
    public static function checkbox(label : String, id : Int, value : Bool)  : Bool
    {
        var v : hl.Ref<Bool> = cast value;
        ImGui.checkbox('$label###$label$id', v);
        return v.get();
    }

    public static function labelText(label : String, id : Int, text : String) 
    {
        ImGui.labelText('$label###$label$id', text);
    }
    //#endregion
}