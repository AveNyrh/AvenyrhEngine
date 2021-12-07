package avenyrh.editor;

import haxe.io.Path;
using Lambda;
import haxe.Int64;
import haxe.EnumTools;
import h2d.Tile;
import avenyrh.gameObject.Component;
import avenyrh.gameObject.SpriteComponent;
import avenyrh.engine.Process;
import avenyrh.gameObject.GameObject;
import avenyrh.imgui.ImGui;
import avenyrh.scene.Scene;
import avenyrh.scene.SceneManager;
import avenyrh.scene.SceneSerializer;
import avenyrh.engine.Uniq;

class Inspector extends EditorPanel
{
    /**
     * Current object being inspected
     */
    public static var currentInspectable : Null<IInspectable>;

    /**
     * Indent space for the hierarchy
     */
    public static inline var indentSpace : Float = 6;

    public static var locked : Bool = false;

    static var fields : Array<String>;
    
    static var rtti : haxe.rtti.CType.Classdef;

    static var textures : Map<h3d.mat.Texture, Int> = [];

    static var labelWidth : Int = 120;

    //-------------------------------
    //#region Public API
    //-------------------------------
    public override function draw(dt : Float)
    {        
        super.draw(dt);

        //#region Hierarchy window
        ImGui.begin("Hierarchy", null, flags);

        var scene : Scene = SceneManager.currentScene;

        //Json
        if(ImGui.button("Serialize",  {x : 100, y : 20}))
            SceneSerializer.serialize(scene);

        ImGui.sameLine(110);

        if(ImGui.button("Deserialize",  {x : 100, y : 20}))
            SceneManager.addScene("TestScene");

        //Change this when having another (de)serialize button placement
        scene = SceneManager.currentScene;

        if(scene == null)
        {
            ImGui.end();
            return;
        }

        ImGui.separator();
        ImGui.spacing();

        var treeNodeFlags : ImGuiTreeNodeFlags = DefaultOpen | SpanAvailWidth | OpenOnArrow;

        //Editor camera
        var editorCam : Camera = editor.sceneWindow.camera;
        var camFlags : ImGuiTreeNodeFlags = treeNodeFlags;
        camFlags |= currentInspectable == editorCam ? Selected : 0;

        if(ImGui.treeNodeEx("Editor camera", treeNodeFlags))
            ImGui.treePop();
        
        if(ImGui.isItemClicked() && !locked)
            currentInspectable = editorCam;

        //Process
        ImGui.spacing();
        if(ImGui.treeNodeEx("Process", treeNodeFlags))
        {
            ImGui.spacing();
            drawHierarchy(scene);
            
            ImGui.treePop();
        }

        ImGui.spacing();
        ImGui.separator();
        var separatorPos : Float = ImGui.getCursorPosY() + 20;
        ImGui.spacing();
        if(ImGui.treeNodeEx("Game", treeNodeFlags))
        {
            for(i in 0 ... @:privateAccess scene.rootGO.length)
            {
                ImGui.spacing();
                drawHierarchy(@:privateAccess scene.rootGO[i]);
            }
            ImGui.treePop();
        }

        if(scene.miscInspectable.length > 0)
        {
            ImGui.separator();
            if(ImGui.treeNodeEx("Misc", treeNodeFlags))
            {
                for(i in scene.miscInspectable)
                {
                    ImGui.spacing();
                    drawHierarchy(i);
                }
                ImGui.treePop();
            }
        }

        //Right click on blank space
        if(ImGui.beginPopupContextWindow("Blank space hierarchy context", 1, false))
        {
            var mousePos : Vector2 = ImGui.getMousePos();
            
            if(mousePos.y < separatorPos)
                addChildProcessMenu(scene);
            else
                addChildGameObjectMenu(scene);
            ImGui.endPopup();
        }

        ImGui.end();
        //#endregion

        //#region Inspector Window
        ImGui.begin("Inspector", null, flags);

        if(currentInspectable != null)
        {
            ImGui.separator();
            currentInspectable.drawInspector();

            //Handle gameObject specific inspector
            if(Std.isOfType(currentInspectable, GameObject))
            {
                //Right click on blank space
                if(ImGui.beginPopupContextWindow("Blank space inspector context", 1, false))
                {
                    //Components that are always present
                    if(ImGui.menuItem("Add SpriteComponent"))
                    {
                        var go : GameObject = cast currentInspectable;
                        go.addComponent(new SpriteComponent("SpriteComponent"));
                    }

                    //Add all custom components dynamicaly
                    ImGui.separator();
                    for(key => value in @:privateAccess editor.data.components) //key = componentName, value = componentClass
                    {
                        if(ImGui.menuItem('Add $key'))
                        {
                            var go : GameObject = cast currentInspectable;
                            go.addComponent(cast Type.createInstance(value, [key]));
                        }
                    }

                    ImGui.endPopup();
                }
            }
        }

        ImGui.end();
        //#endregion
    }

    public override function close()
    {
        super.close();

        currentInspectable = null;
    }
    //#endregion

    //-------------------------------
    //#region Private API
    //-------------------------------
    function drawHierarchy(inspectable : IInspectable)
    {
        var name : String = "";
        var uID : String = "";
        var children : Array<Dynamic> = [];

        var go : Null<GameObject> = null;
        var proc : Null<Process> = null;

        if(Std.isOfType(inspectable, GameObject))
        {
            go = cast inspectable;
            name = go.name;
            uID = Int64.toStr(go.uID);
            children = cast go.children;
        }
        else if(Std.isOfType(inspectable, Process))
        {
            proc = cast inspectable;
            name = proc.name;
            uID = Int64.toStr(proc.uID);
            children = cast proc.children;
        }

        ImGui.indent(Inspector.indentSpace);

        var treeNodeFlags : ImGuiTreeNodeFlags = OpenOnArrow | DefaultOpen | SpanAvailWidth;
        if(Inspector.currentInspectable == inspectable)
            treeNodeFlags |= Selected;

        var open : Bool = ImGui.treeNodeEx('$name###$name$uID', treeNodeFlags);

        if(ImGui.isItemClicked() && !locked)
            currentInspectable = inspectable;

        if(ImGui.isMouseDoubleClicked(0) && ImGui.isItemHovered() && go != null)
            editor.sceneWindow.centerScreenOn(go.absX, go.absY);

        //Righ click pop up
        if(ImGui.beginPopupContextWindow('HierarchyItemSettings##$uID'))
        {
            if(go != null)
            {
                if(ImGui.menuItem("Destroy GameObject"))
                    go.destroy();

                
                ImGui.separator();
                var child = addChildGameObjectMenu(SceneManager.currentScene);
                if(child != null)
                    go.addChild(child);
            }
            else if(proc != null)
            {
                if(ImGui.menuItem("Destroy process"))
                    proc.destroy();

                ImGui.separator();
                var child = addChildProcessMenu(SceneManager.currentScene);
                if(child != null)
                    proc.addChild(child);
            }
            ImGui.endPopup();
        }

        //Drag drop
        //Source
        if(ImGui.beginDragDropSource())
        {
            if(go != null)
            {
                ImGui.setDragDropPayloadString(EditorPanel.ddGameObjectInspector, uID);
                ImGui.setTooltip(go.name);
            }
            else if(proc != null)
            {
                ImGui.setDragDropPayloadString(EditorPanel.ddProcessInspector, uID);
                ImGui.setTooltip(proc.name);
            }
            ImGui.endDragDropSource();
        }

        //Target
        if(ImGui.beginDragDropTarget())
        {
            if(go != null)
            {
                var goUID : String = ImGui.acceptDragDropPayloadString(EditorPanel.ddGameObjectInspector);
                var g : GameObject = SceneManager.currentScene.getGameObjectFromUID(goUID);
                if(g != null && !go.getParentRec().contains(g) && goUID != uID)
                {
                    go.addChild(g);
                }
            }
            else if(proc != null)
            {
                var procUID : String = ImGui.acceptDragDropPayloadString(EditorPanel.ddGameObjectInspector);
                var p : Process = SceneManager.currentScene.getChildRec(procUID);
                if(p != null && !proc.getParentRec().contains(p) && procUID != uID)
                {
                    proc.addChild(p);
                }
            }
            ImGui.endDragDropTarget();
        }

        if(open)
        {   
            for(c in children)
                drawHierarchy(cast c);

            ImGui.treePop();
        }

        ImGui.unindent(Inspector.indentSpace);
    }

    function addChildProcessMenu(scene : Scene) : Null<Process>
    {
        var proc : Process = null;

        for(key => value in @:privateAccess editor.data.processes) //key = menu item, value = class
        {
            if(ImGui.menuItem('New $key'))
                proc = cast Type.createInstance(value, [key, null, scene]);
        }

        if(proc != null)
            scene.addChild(proc);

        return proc;
    }

    function addChildGameObjectMenu(scene : Scene) : Null<GameObject>
    {
        var go : GameObject = null;
        if(ImGui.menuItem("New Empty GameObject"))
            go = new GameObject("New GameObject", null, scene);

        ImGui.separator();

        for(key => value in @:privateAccess editor.data.gameObjects) //key = menu item, value = class
        {
            if(ImGui.menuItem('New $key'))
                go = cast Type.createInstance(value, [key, null, scene]);
        }

        if(go != null)
            scene.addGameObject(go);

        return go;
    }

    static function getClassNameFromRttiField(field : haxe.rtti.CType.ClassField) : String
    {
        switch (field.type)
        {
            case CClass(name, params) :
                var f : Array<String> = name.split(".");
                return f[f.length - 1];
            
            case _ :
                return null;
        }
    }
    //#endregion

    //-------------------------------
    //#region Static API
    //-------------------------------
    /**
     * Draws the parameter fields on the Inspector
     */
    public static function drawInInspector(u : Uniq) 
    {
        fields = Reflect.fields(u);
        rtti = haxe.rtti.Rtti.getRtti(Type.getClass(u));

        for(f in rtti.fields)
        {
            if(f.isPublic && !f.meta.exists(m -> m.name == "hideInInspector") || f.meta.exists(m -> m.name == "serializable"))
            {
                if(fields.contains(f.name))
                {
                    var d : Dynamic = Inspector.drawField(u, f, Reflect.getProperty(u, f.name));

                    if(d != null)
                        Reflect.setProperty(u, f.name, d);
                }
            }
        }
    }

    public static function drawComponent(component : Component)
    {
        var availableSpace : ImVec2 = ImGui.getContentRegionAvail();
        var flags : ImGuiTreeNodeFlags = DefaultOpen | SpanAvailWidth | AllowItemOverlap;
        var open : Bool = ImGui.collapsingHeader('${component.name}###${component.name}${component.uID}', flags);

        var buttonSize : Int = 19; 
        ImGui.sameLine(availableSpace.x - buttonSize / 2 + 4);
        if(ImGui.button('+##${component.uID}', {x : buttonSize, y : buttonSize}))
            ImGui.openPopup('ComponentSettings##${component.uID}');

        ImGui.spacing();
        if(open)
            @:privateAccess component.drawInfo();

        //Pop up for the "+" button
        var removeComponent : Bool = false;
        if(ImGui.beginPopup('ComponentSettings##${component.uID}'))
        {
            if(ImGui.menuItem("Remove component"))
                removeComponent = true;

            ImGui.endPopup();
        }

        if(removeComponent)
            component.gameObject.removeComponent(component);
    }

    static var fv : Array<Float>;
    static var minf : Float;
    static var maxf : Float;
    static var iv : Array<Int>;
    static var mini : Int;
    static var maxi : Int;
    static var vec2 : Vector2;
    static var tile : Tile;
    static var ev : EnumValue;
    static var e : Enum<Dynamic>;
    static var go : GameObject;
    static var comp : Component;
    static var index : Int = 0;
    static var na : hl.NativeArray<Single>;
    static var s : Sprite;

    public static function drawField<T>(u : Uniq, field : haxe.rtti.CType.ClassField, value : Dynamic) : Dynamic
    {
        switch (field.type)
        {
            case CAbstract("Float", []) : //Float
                fv = [cast value];

                if(field.meta.exists(m -> m.name == "range"))
                {
                    minf = Std.parseFloat(field.meta.find(m -> m.name == "range").params[0]);
                    maxf = Std.parseFloat(field.meta.find(m -> m.name == "range").params[1]);
                    Inspector.sliderFloats(field.name, u.uID, fv, minf, maxf);
                }
                else
                    Inspector.dragFloats(field.name, u.uID, fv);

                return cast fv[0];

            case CAbstract("Int", []) : //Int
                iv = [cast value];

                if(field.meta.exists(m -> m.name == "range"))
                {
                    mini = Std.parseInt(field.meta.find(m -> m.name == "range").params[0]);
                    maxi = Std.parseInt(field.meta.find(m -> m.name == "range").params[1]);
                    Inspector.sliderInts(field.name, u.uID, iv, mini, maxi);
                }
                else
                    Inspector.dragInts(field.name, u.uID, iv);

                return cast iv[0];

            case CAbstract("Bool", []) : //Bool
                return cast Inspector.checkbox(field.name, u.uID, cast value);

            case CClass("String", []) : //String
                return Inspector.inputText(field.name, u.uID, cast value);

            case CEnum(_, []) : //Enum
                ev = cast Reflect.getProperty(u, field.name);
                e = Type.getEnum(ev);
                index = Inspector.enumDropdown(field.name, u.uID, e, ev.getIndex());
                return EnumTools.createByIndex(e, index);

            case CAbstract("avenyrh.Vector2", []) : //Vector2
                vec2 = Reflect.getProperty(u, field.name);
                vec2 = Inspector.dragVector2(field.name, u.uID, vec2, 0.1);
                return vec2;

            case CClass("h2d.Tile", []) : //Tile
                tile = cast(Reflect.getProperty(u, field.name), Tile);
                Inspector.image(field.name, tile);
                return tile;

            case CClass("avenyrh.Sprite", []) : //Sprite
                s = Reflect.getProperty(u, field.name);
                setDragDropStyle();
                if(s != null)
                    Inspector.labelButton(field.name, Std.string(s.filePath), u.uID, cast(ImGui.getWindowContentRegionWidth() - labelWidth - 32));
                else 
                    Inspector.labelButton(field.name, "Null", u.uID, cast(ImGui.getWindowContentRegionWidth() - labelWidth - 32));
                ImGui.popStyleColor(4);
                
                //Drag drop
                if(ImGui.beginDragDropTarget())
                {
                    ImGui.acceptDragDropPayloadString(EditorPanel.ddSpriteContent);
                    if(!ImGui.isMouseDown(0))
                    {
                        var sprite : Sprite = EditorPanel.Editor.contentWindow.currentSprite;
    
                        if(sprite != null)
                            s = sprite;
                    }
    
                    ImGui.endDragDropTarget();
                }
    
                ImGui.sameLine();
                if(ImGui.button("X##sprite", {x : 20, y : 20}))
                    s = null;

                Reflect.setProperty(u, field.name, s);
                return null;

            default :
                var f : String = getClassNameFromRttiField(field);
                if(@:privateAccess EditorPanel.Editor.data.gameObjects.exists(f) || field.type.match(CClass("avenyrh.gameObject.GameObject", []))) //GameObjects
                {
                    go = cast(Reflect.getProperty(u, field.name), GameObject);
                    setDragDropStyle();
                    if(go != null)
                        Inspector.labelButton(field.name, go.name, u.uID, cast(ImGui.getWindowContentRegionWidth() - labelWidth - 32));
                    else 
                        Inspector.labelButton(field.name, "Null", u.uID, cast(ImGui.getWindowContentRegionWidth() - labelWidth - 32));
                    ImGui.popStyleColor(4);
    
                    //Drag drop
                    if(ImGui.beginDragDropTarget())
                    {
                        var goUID : String = ImGui.acceptDragDropPayloadString(EditorPanel.ddGameObjectInspector);
                        var g : GameObject = SceneManager.currentScene.getGameObjectFromUID(goUID);
    
                        if(g != null)
                        {
                            go = g;
                        }
    
                        ImGui.endDragDropTarget();
                    }
    
                    ImGui.sameLine();
                    if(ImGui.button("X##go", {x : 20, y : 20}))
                        go = null;

                    Reflect.setProperty(u, field.name, go);
                }
                else if(@:privateAccess EditorPanel.Editor.data.components.exists(f)) //Components
                {
                    comp = cast(Reflect.getProperty(u, field.name), Component);
                    ImGui.pushStyleColor(Button, Color.rgbaToInt({r : 0, g : 0, b : 0, a : 0}));
                    ImGui.pushStyleColor(ButtonHovered, Color.rgbaToInt({r : 0, g : 0, b : 0, a : 0}));
                    ImGui.pushStyleColor(ButtonActive, Color.rgbaToInt({r : 0, g : 0, b : 0, a : 0}));
                    ImGui.pushStyleColor(Border, Color.rgbaToInt({r : 0, g : 0, b : 0, a : 0}));
                    if(comp != null)
                        Inspector.labelButton(field.name, '${comp.gameObject.name}.${comp.name}', u.uID, cast(ImGui.getWindowContentRegionWidth() - labelWidth - 32));
                    else 
                        Inspector.labelButton(field.name, "Null", u.uID, cast(ImGui.getWindowContentRegionWidth() - labelWidth - 32));
                    ImGui.popStyleColor(4);
    
                    //Drag drop
                    if(ImGui.beginDragDropTarget())
                    {
                        var goUID : String = ImGui.acceptDragDropPayloadString(EditorPanel.ddGameObjectInspector);
                        var g : GameObject = SceneManager.currentScene.getGameObjectFromUID(goUID);
    
                        if(g != null)
                        {
                            var c : Null<Component> = g.getComponentByName(f);
                            if(c != null)
                                comp = c;
                        }
    
                        ImGui.endDragDropTarget();
                    }

                    ImGui.sameLine();
                    if(ImGui.button("X##comp", {x : 20, y : 20}))
                        comp = null;

                    Reflect.setProperty(u, field.name, comp);
                }
                
                return null;
        }
    }

    static function setDragDropStyle()
    {
        ImGui.pushStyleColor(Button, Color.rgbaToInt({r : 0, g : 0, b : 0, a : 0}));
        ImGui.pushStyleColor(ButtonHovered, Color.rgbaToInt({r : 0, g : 0, b : 0, a : 0}));
        ImGui.pushStyleColor(ButtonActive, Color.rgbaToInt({r : 0, g : 0, b : 0, a : 0}));
        ImGui.pushStyleColor(Border, Color.rgbaToInt({r : 0, g : 0, b : 0, a : 0}));
    }

    static function drawLabel(label : String)
    {
        ImGui.columns(2);
        ImGui.setColumnWidth(0, labelWidth);
        ImGui.pushItemWidth(labelWidth);
        ImGui.labelText('##$label', label);
        ImGui.popItemWidth();
        ImGui.nextColumn();
        ImGui.pushItemWidth(ImGui.getWindowWidth() - labelWidth - 20);
    }

    static function endField()
    {
        ImGui.popItemWidth();
        ImGui.columns(1);
    }

    /**
     * Returns the changed value
     */
    public static function inputFloat(label : String, id : Int64, data : Float, step : Float = 0.1, format : String = "%.3f") : Float
    {
        drawLabel(label);
        var value = new hl.Ref<Float>(data);
        ImGui.inputDouble('##$label$id', value, step, step, format);

        endField();
        return data;
    }

    /**
     * Returns true if one of the values has changed
     */
    public static function inputFloats(label : String, id : Int64, data : Array<Float>, format : String = "%.3f") : Bool
    {
        drawLabel(label);
        na = new hl.NativeArray<Single>(data.length);
        var changed : Bool = false;

        for(i in 0 ... data.length)
            na[i] = data[i];

        if(ImGui.inputFloat2('##$label$id', na, format))
        {
            changed = true;
            for(i in 0 ... data.length)
                data[i] = na[i];
        }

        endField();
        return changed;
    }

    /**
     * Returns true if one of the values has changed
     */
    public static function dragFloats(label : String, id : Int64, data : Array<Float>, step : Float = 1, format : String = "%.3f") : Bool
    {
        drawLabel(label);
        na = new hl.NativeArray<Single>(data.length);
        var changed : Bool = false;

        for(i in 0 ... data.length)
            na[i] = data[i];

        if(ImGui.dragFloat('##$label$id', na, step, format))
        {
            changed = true;
            for(i in 0 ... data.length)
                data[i] = na[i];
        }

        endField();
        return changed;
    }

    /**
     * Returns true if one of the values has changed
     */
    public static function sliderFloats(label : String, id : Int64, data : Array<Float>, min : Float, max : Float, format : String = "%.3f") : Bool
    {
        drawLabel(label);
        na = new hl.NativeArray<Single>(data.length);
        var changed : Bool = false;

        for(i in 0 ... data.length)
            na[i] = data[i];

        if(ImGui.sliderFloat('##$label$id', na, min, max, format))
        {
            changed = true;
            for(i in 0 ... data.length)
                data[i] = na[i];
        }

        endField();
        return changed;
    }

    /**
     * Returns the changed value
     */
    public static function inputInt(label : String, id : Int64, data : Int) : Int
    {
        drawLabel(label);
        var f : Float = cast data;
        var value = new hl.Ref<Float>(f);

        ImGui.inputDouble('##$label$id', value, 1, 1, "%.0f");

        endField();
        return AMath.floor(f);
    }
    
    /**
     * Returns true if one of the values has changed
     */
    public static function dragInts(label : String, id : Int64, data : Array<Int>, step : Float = 1) : Bool
    {
        drawLabel(label);
        var na = new hl.NativeArray<Int>(data.length);
        var changed : Bool = false;

        for(i in 0 ... data.length)
            na[i] = data[i];

        if(ImGui.dragInt('##$label$id', na, step))
        {
            changed = true;
            for(i in 0 ... data.length)
                data[i] = na[i];
        }

        endField();
        return changed;
    }

    /**
     * Returns true if one of the values has changed
     */
    public static function sliderInts(label : String, id : Int64, data : Array<Int>, min : Int, max : Int) : Bool
    {
        drawLabel(label);
        var na = new hl.NativeArray<Int>(data.length);
        var changed : Bool = false;

        for(i in 0 ... data.length)
            na[i] = data[i];

        if(ImGui.sliderInt('##$label$id', na, min, max))
        {
            changed = true;
            for(i in 0 ... data.length)
                data[i] = na[i];
        }

        endField();
        return changed;
    }

    /**
     * Returns the index of the selected enum value
     */
    public static function enumDropdown<T>(label : String, id : Int64, e : Enum<T>, index : Int, maxItemShown : Int = 4) : Int
    {
        drawLabel(label);
        var changed : Bool = false;
        var ea : Array<T> = haxe.EnumTools.createAll(e);
        var na = new hl.NativeArray<String>(ea.length);

        for(i in 0 ... ea.length)
            na[i] = Std.string(ea[i]);

        if(ImGui.beginCombo('##$label$id', na[index]))
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

        endField();
        return index;
    }

    public static function button(label : String, id : Int64, width : Int = 200, height : Int = 20) : Bool
    {
        return ImGui.button('$label##$label$id', {x : width, y : height});
    }

    public static function labelButton(label : String, textButton : String, id : Int64, width : Int = 200, height : Int = 20) : Bool
    {
        drawLabel(label);
        var b : Bool = ImGui.button('$textButton##$label$id', {x : width, y : height});
        endField();
        return b;
    }

    /**
     * Returns the value of the checkbox
     */
    public static function checkbox(label : String, id : Int64, value : Bool)  : Bool
    {
        drawLabel(label);
        var v : hl.Ref<Bool> = cast value;
        ImGui.checkbox('##$label$id', v);

        endField();
        return v.get();
    }

    public static function inputText(label : String, id : Int64, text : String) : String
    {
        drawLabel(label);
        var input_text_buffer = new hl.Bytes(128);
        input_text_buffer = @:privateAccess text.toUtf8();

        if (ImGui.inputText('##$label$id', input_text_buffer, 128)) 
        {
            var st = @:privateAccess String.fromUTF8(input_text_buffer);
            text = st;
        }

        endField();
        return text;
    }

    public static function labelText(label : String, text : String) 
    {
        drawLabel(label);
        ImGui.text(text);
        endField();
    }

    public static function image(label : String, tile : Tile) @:privateAccess
    {
        drawLabel(label);
        ImGui.image(tile.getTexture(), {x : tile.width, y : tile.height}, {x : tile.u, y : tile.v}, {x : tile.u2, y : tile.v2});
        endField();
    }

    /**
     * Returns true if one of the values has changed
     */
    public static function inputVector2(label : String, id : Int64, vec : Vector2, step : Float = 0.1, format : String = "%.3f") : Vector2
    {
        drawLabel(label);

        var x = new hl.Ref<Float>(vec.x);
        var y = new hl.Ref<Float>(vec.y);
        ImGui.inputDouble('##x$label$id', x, step, step, format);
        ImGui.sameLine();
        ImGui.text("X");
        ImGui.inputDouble('##y$label$id', y, step, step, format);
        ImGui.sameLine();
        ImGui.text("Y");

        endField();
        return vec;
    }

    /**
     * Returns the vector2 changed
     */
    public static function dragVector2(label : String, id : Int64, vec : Vector2, step : Float = 0.1, resetValue : Float = 0, format : String = "%.3f") : Vector2
    {
        drawLabel(label);

        var space = ImGui.calcItemWidth();
        var buttonSize = 20;
        var dragSize = space / 2 - 2 * buttonSize + 8.5;
        var x = new hl.NativeArray<Single>(1);
        x[0] = vec.x;
        var y = new hl.NativeArray<Single>(1);
        y[0] = vec.y;
        
        ImGui.pushStyleColor2(Button, {x : 0.8, y : 0.1, z : 0.15, w : 1});
        ImGui.pushStyleColor2(ButtonHovered, {x : 0.9, y : 0.2, z : 0.2, w : 1});
        ImGui.pushStyleColor2(ButtonActive, {x : 0.8, y : 0.1, z : 0.15, w : 1});
        if(ImGui.button('X##$label', {x : buttonSize, y : buttonSize}))
            x[0] = resetValue;
        ImGui.popStyleColor(3);
        ImGui.sameLine();
        ImGui.pushItemWidth(dragSize);
        ImGui.dragFloat('##x$label$id', x, step, step, format);
        ImGui.popItemWidth();
        ImGui.sameLine();

        ImGui.pushStyleColor2(Button, {x : 0.1, y : 0.6, z : 0.1, w : 1});
        ImGui.pushStyleColor2(ButtonHovered, {x : 0.2, y : 0.7, z : 0.2, w : 1});
        ImGui.pushStyleColor2(ButtonActive, {x : 0.1, y : 0.6, z : 0.1, w : 1});
        if(ImGui.button('Y##$label', {x : buttonSize, y : buttonSize}))
            y[0] = resetValue;
        ImGui.popStyleColor(3);
        ImGui.sameLine();
        ImGui.pushItemWidth(dragSize);
        ImGui.dragFloat('##y$label$id', y, step, step, format);
        ImGui.popItemWidth();

        endField();
        return new Vector2(x[0], y[0]);
    }

    public static function colorPicker(label : String, id : Int64, color : h3d.Vector) : h3d.Vector
    {
        drawLabel(label);
        na = new hl.NativeArray<Single>(3);
        na[0] = color.r;
        na[1] = color.g;
        na[2] = color.b;
        ImGui.colorEdit3('##$label$id', na);
        color.r = cast na[0];
        color.g = cast na[1];
        color.b = cast na[2];
        endField();

        return color;
    }
    //#endregion
}