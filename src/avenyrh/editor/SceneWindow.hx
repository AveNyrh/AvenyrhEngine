package avenyrh.editor;

import avenyrh.gameObject.GameObject;
import avenyrh.scene.Scene;
import avenyrh.scene.SceneManager;
import avenyrh.imgui.ImGui;
import h3d.mat.Texture;

class SceneWindow extends EditorPanel
{
    public var width (default, null) : Int = 0;

    public var height (default, null) : Int = 0;

    public var sceneTex : Texture = null;

    public var camera : Camera = null;

    //Camera movement settings
    var left : Int = hxd.Key.Q;
    var right : Int = hxd.Key.D;
    var up : Int = hxd.Key.Z;
    var down : Int = hxd.Key.S;
    var mvt : avenyrh.Vector2 = avenyrh.Vector2.ZERO;
    var mvtSpeed : Float = 2;
    var zoomSpeed : Float = 0.1;

    override function init() 
    {
        var scene : Scene = SceneManager.currentScene;
        setScene(scene);
    }

    public override function draw(dt : Float)
    {        
        super.draw(dt);

        updateCamera(dt);

        flags |= MenuBar;

        //Scene window
        ImGui.begin("Scene", null, flags);

        width = cast ImGui.getWindowWidth();
        height = cast ImGui.getWindowHeight() - 60;

        //Main menu bar
        if(ImGui.beginMenuBar())
        {
            ImGui.text('$width x $height');
        
            ImGui.endMenuBar();
        }

        //Scene image
        ImGui.image(sceneTex, {x : width, y : height});

        var go : Null<GameObject> = cast Inspector.currentInspectable;
        if(go != null)
        {
            mousePos = ImGui.getMousePos();

            drawTranslationGuizmo(go);

            oldMousePos = mousePos;
        }
        
        ImGui.end();
    }

    public function setScene(scene : Scene)
    {
        if(camera != null)
            camera.destroy();

        camera = new Camera("Editor camera", scene);
        scene.removeChild(camera);
        scene.camera.pause();

        @:privateAccess camera.forcePosition(260, 120);
        camera.zoom = 1.6;
    }

    function updateCamera(dt : Float)
    {
        mvt = avenyrh.Vector2.ZERO;

        if(hxd.Key.isDown(left))
            mvt.x = 1;
        if(hxd.Key.isDown(right))
            mvt.x = -1;
        if(hxd.Key.isDown(up))
            mvt.y = 1;
        if(hxd.Key.isDown(down))
            mvt.y = -1;

        if(hxd.Key.isPressed(hxd.Key.MOUSE_WHEEL_UP))
            camera.zoom += zoomSpeed;
        else if(hxd.Key.isPressed(hxd.Key.MOUSE_WHEEL_DOWN))
            camera.zoom -= zoomSpeed;

        mvt = mvt.normalize();
        camera.move(mvt.x * mvtSpeed / camera.zoom, mvt.y * mvtSpeed / camera.zoom);
        @:privateAccess camera.update(dt);
        @:privateAccess camera.postUpdate(dt);
    }

    //--------------------
    //#region Private API
    //--------------------
    //Transform guizmo settings
    var lineThickness : Float = 4;
    var circleRadius : Float = 4;
    var axisLength : Float = 30;
    var xAxisColor : Int = Color.iBLUE;
    var yAxisColor : Int = Color.iGREEN;
    var circleColor : Int = Color.iWHITE;
    var highlightColor : Int = Color.iCYAN;

    var oldMousePos : Vector2 = Vector2.ZERO;
    var mousePos : Vector2 = Vector2.ZERO;

    function drawTranslationGuizmo(go : GameObject)
    {
        var drawList : ImDrawList = ImGui.getForegroundDrawList();
        var windowOrigin : Vector2 = ImGui.getWindowPos();
        var upLeft : Vector2 = new Vector2(2, 40);
        upLeft += windowOrigin;
        var origin : Vector2 = upLeft + Vector2.ONE * 100;
        var xEnd : Vector2 = origin + Vector2.RIGHT * axisLength;
        var yEnd : Vector2 = origin + Vector2.DOWN * axisLength;
        var xLineOffset : Vector2 = Vector2.DOWN * -lineThickness / 4;
        var yLineOffset : Vector2 = Vector2.RIGHT * -lineThickness / 4;

        //Mouse inside arrows
        var isInX : Bool = mousePos.x >= origin.x + 2 && mousePos.x <= xEnd.x + 6 && 
            mousePos.y >= origin.y - lineThickness / 2 && mousePos.y <= origin.y + lineThickness / 2;
        var isInY : Bool = mousePos.y <= origin.y - 2 && mousePos.y >= yEnd.y - 6 && 
            mousePos.x >= origin.x - lineThickness / 2 && mousePos.x <= origin.x + lineThickness / 2;
        var isInCircle = isInsideCircle(origin, circleRadius);

        //Mouse movement
        var deltaX : Float = mousePos.x - oldMousePos.x;
        var deltaY : Float = mousePos.y - oldMousePos.y;
        if(ImGui.isMouseDown(0))
        {
            if(isInX && deltaX != 0)
                go.move(deltaX, 0);
            else if(isInY && deltaY != 0)
                go.move(0, deltaY);
            else if(isInCircle && deltaX != 0 && deltaY != 0)
                go.move(deltaX, deltaY);
        }

        //X axis
        drawList.addLine(origin, xEnd, isInX ? highlightColor : xAxisColor, lineThickness);

        var p1 : Vector2 = xEnd + xLineOffset + Vector2.DOWN * 5;
        var p2 : Vector2 = xEnd + xLineOffset + Vector2.DOWN * -5;
        var p3 : Vector2 = xEnd + xLineOffset + Vector2.RIGHT * 6;
        drawList.addTriangleFilled(p1, p2, p3, isInX ? highlightColor : xAxisColor);

        //Y axis
        drawList.addLine(origin + yLineOffset, yEnd + yLineOffset, isInY ? highlightColor : yAxisColor, lineThickness);

        var yTriangleOffset : Vector2 = Vector2.DOWN * -1;
        p1 = yEnd + yTriangleOffset + Vector2.RIGHT * -5;
        p2 = yEnd + yTriangleOffset + Vector2.RIGHT * 5;
        p3 = yEnd + yTriangleOffset + Vector2.DOWN * 6;
        drawList.addTriangleFilled(p1, p2, p3, isInY ? highlightColor : yAxisColor);

        //Center circle
        drawList.addCircleFilled(origin, circleRadius, isInCircle ? highlightColor : Color.iWHITE, 20);
    }

    function isInsideCircle(origin : Vector2, radius : Float) : Bool
    {

        
        return false;
    }
    //#endregion
}