package avenyrh.editor;

import avenyrh.imgui.ImGui;
import avenyrh.imgui.ImGuiDrawable;
import avenyrh.engine.Process;

class Editor extends Process
{
    public var menuBar : EditorMenuBar;

    public var inspector : Inspector;

    public var sceneWindow : SceneWindow;

    public var contentWindow : ContentWindow;

    var enable : Bool = true;

    var drawable : ImGuiDrawable;

    var data : IEditorData;

    override public function new(data : IEditorData) 
    {
        super("Editor");

        createRoot(Process.S2D, 10);
        drawable = new ImGuiDrawable(root);
        this.data = data;

        ImGui.loadIniSettingsFromDisk("default.ini");
        ImGui.setConfigFlags(ImGuiConfigFlags.DockingEnable);

        @:privateAccess EditorPanel.Editor = this;

        menuBar = new EditorMenuBar();
        inspector = new Inspector();
        sceneWindow = new SceneWindow();
        contentWindow = new ContentWindow();

        applyDefaultStyle();
    }

    //-------------------------------
    //#region Private API
    //-------------------------------
    override function update(dt : Float) 
    {
        super.update(dt);

        if(hxd.Key.isPressed(hxd.Key.F4))
            inspector.enable ? inspector.close() : inspector.open();
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

        var windowFlags : ImGuiWindowFlags = ImGuiWindowFlags.NoCollapse | ImGuiWindowFlags.NoResize | ImGuiWindowFlags.NoMove | ImGuiWindowFlags.NoBackground;
        windowFlags |= ImGuiWindowFlags.NoBringToFrontOnFocus | ImGuiWindowFlags.NoNavFocus;
        ImGui.begin("Dockspace window", null, windowFlags);
        var id : Int = ImGui.getID("Dockspace");
        var dockFlags : ImGuiDockNodeFlags = ImGuiDockNodeFlags.None;
        ImGui.dockSpace(id, {x : 0, y : 0}, dockFlags);

        //ImGui.showDemoWindow();

        menuBar.draw(dt);
        inspector.draw(dt);
        sceneWindow.draw(dt);
        contentWindow.draw(dt);

        ImGui.end();
        ImGui.render();
        ImGui.endFrame();
    }

    function applyDefaultStyle()
    {
        var style : ImGuiStyle = ImGui.getStyle();
        var colors : hl.NativeArray<ImVec4> = style.Colors;

        colors[Text]                   = cast {x : 0.900, y : 0.900, z : 0.900, w : 1.000};
	    colors[TextDisabled]           = cast {x : 0.500, y : 0.500, z : 0.500, w : 1.000};
	    colors[WindowBg]               = cast {x : 0.180, y : 0.180, z : 0.180, w : 1.000};
	    colors[ChildBg]                = cast {x : 0.280, y : 0.280, z : 0.280, w : 0.000};
	    colors[PopupBg]                = cast {x : 0.313, y : 0.313, z : 0.313, w : 1.000};
	    colors[Border]                 = cast {x : 0.266, y : 0.266, z : 0.266, w : 1.000};
	    colors[BorderShadow]           = cast {x : 0.000, y : 0.000, z : 0.000, w : 0.000};
	    colors[FrameBg]                = cast {x : 0.160, y : 0.160, z : 0.160, w : 1.000};
	    colors[FrameBgHovered]         = cast {x : 0.200, y : 0.200, z : 0.200, w : 1.000};
	    colors[FrameBgActive]          = cast {x : 0.280, y : 0.280, z : 0.280, w : 1.000};
	    colors[TitleBg]                = cast {x : 0.148, y : 0.148, z : 0.148, w : 1.000};
	    colors[TitleBgActive]          = cast {x : 0.148, y : 0.148, z : 0.148, w : 1.000};
	    colors[TitleBgCollapsed]       = cast {x : 0.148, y : 0.148, z : 0.148, w : 1.000};
	    colors[MenuBarBg]              = cast {x : 0.195, y : 0.195, z : 0.195, w : 1.000};
	    colors[ScrollbarBg]            = cast {x : 0.160, y : 0.160, z : 0.160, w : 1.000};
	    colors[ScrollbarGrab]          = cast {x : 0.277, y : 0.277, z : 0.277, w : 1.000};
	    colors[ScrollbarGrabHovered]   = cast {x : 0.300, y : 0.300, z : 0.300, w : 1.000};
	    colors[ScrollbarGrabActive]    = cast {x : 0.212, y : 0.658, z : 0.990, w : 1.000};
	    colors[CheckMark]              = cast {x : 1.000, y : 1.000, z : 1.000, w : 1.000};
	    colors[SliderGrab]             = cast {x : 0.391, y : 0.391, z : 0.391, w : 1.000};
	    colors[SliderGrabActive]       = cast {x : 0.212, y : 0.658, z : 0.990, w : 1.000};
	    colors[Button]                 = cast {x : 1.000, y : 1.000, z : 1.000, w : 0.000};
    	colors[ButtonHovered]          = cast {x : 1.000, y : 1.000, z : 1.000, w : 0.156};
	    colors[ButtonActive]           = cast {x : 1.000, y : 1.000, z : 1.000, w : 0.391};
	    colors[Header]                 = cast {x : 0.313, y : 0.313, z : 0.313, w : 1.000};
	    colors[HeaderHovered]          = cast {x : 0.469, y : 0.469, z : 0.469, w : 1.000};
	    colors[HeaderActive]           = cast {x : 0.469, y : 0.469, z : 0.469, w : 1.000};
	    colors[Separator]              = colors[Border];
	    colors[SeparatorHovered]       = cast {x : 0.391, y : 0.391, z : 0.391, w : 1.000};
	    colors[SeparatorActive]        = cast {x : 0.212, y : 0.658, z : 0.990, w : 1.000};
	    colors[ResizeGrip]             = cast {x : 1.000, y : 1.000, z : 1.000, w : 0.250};
	    colors[ResizeGripHovered]      = cast {x : 1.000, y : 1.000, z : 1.000, w : 0.670};
	    colors[ResizeGripActive]       = cast {x : 1.000, y : 0.391, z : 0.000, w : 1.000};
	    colors[ImGuiCol.Tab]           = cast {x : 0.098, y : 0.098, z : 0.098, w : 1.000};
	    colors[TabHovered]             = cast {x : 0.352, y : 0.352, z : 0.352, w : 1.000};
	    colors[TabActive]              = cast {x : 0.195, y : 0.195, z : 0.195, w : 1.000};
	    colors[TabUnfocused]           = cast {x : 0.098, y : 0.098, z : 0.098, w : 1.000};
	    colors[TabUnfocusedActive]     = cast {x : 0.195, y : 0.195, z : 0.195, w : 1.000};
	    //colors[DockingPreview]         = cast {x : 1.000, y : 0.391, z : 0.000, w : 0.781};
	    //colors[DockingEmptyBg]         = cast {x : 0.180, y : 0.180, z : 0.180, w : 1.000};
	    colors[PlotLines]              = cast {x : 0.469, y : 0.469, z : 0.469, w : 1.000};
	    colors[PlotLinesHovered]       = cast {x : 0.212, y : 0.658, z : 0.990, w : 1.000};
	    colors[PlotHistogram]          = cast {x : 0.586, y : 0.586, z : 0.586, w : 1.000};
	    colors[PlotHistogramHovered]   = cast {x : 0.212, y : 0.658, z : 0.990, w : 1.000};
	    colors[TextSelectedBg]         = cast {x : 1.000, y : 1.000, z : 1.000, w : 0.156};
	    colors[DragDropTarget]         = cast {x : 0.212, y : 0.658, z : 0.990, w : 1.000};
	    colors[NavHighlight]           = cast {x : 0.212, y : 0.658, z : 0.990, w : 1.000};
	    colors[NavWindowingHighlight]  = cast {x : 0.212, y : 0.658, z : 0.990, w : 1.000};
	    colors[NavWindowingDimBg]      = cast {x : 0.000, y : 0.000, z : 0.000, w : 0.586};
	    colors[ModalWindowDimBg]       = cast {x : 0.000, y : 0.000, z : 0.000, w : 0.586};

        style.ChildRounding            = 4.0;
        style.FrameBorderSize          = 1.0;
        style.FrameRounding            = 2.0;
        style.GrabMinSize              = 7.0;
        style.PopupRounding            = 2.0;
        style.ScrollbarRounding        = 12.0;
        style.ScrollbarSize            = 13.0;
        style.TabBorderSize            = 1.0;
        style.TabRounding              = 0.0;
        style.WindowRounding           = 4.0;

        ImGui.setStyle(style);
    }
    //#endregion
}