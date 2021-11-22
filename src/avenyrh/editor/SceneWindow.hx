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

    public var mode : TransformMode = TRANSLATE;

    public var operation : TransformOperation = NONE;

    var windowOffset : Vector2 = new Vector2(8, 46);

    //Camera movement settings
    var left : Int = hxd.Key.Q;
    var right : Int = hxd.Key.D;
    var up : Int = hxd.Key.Z;
    var down : Int = hxd.Key.S;
    var mvt : avenyrh.Vector2 = avenyrh.Vector2.ZERO;
    var mvtSpeed : Float = 2;
    var zoomSpeed : Float = 0.1;

    //Mode inputs
    var translate : Int = hxd.Key.NUMBER_1;
    var rotate : Int = hxd.Key.NUMBER_2;
    var scale : Int = hxd.Key.NUMBER_3;

    override function init() 
    {
        var scene : Scene = SceneManager.currentScene;
        setScene(scene);
    }

    public override function draw(dt : Float)
    {        
        super.draw(dt);

        updateControls(dt);

        flags |= MenuBar;

        //Scene window
        ImGui.begin("Scene", null, flags);

        width = cast ImGui.getWindowWidth();
        height = cast ImGui.getWindowHeight() - 60;

        //Main menu bar
        if(ImGui.beginMenuBar())
        {
            ImGui.text('$width x $height');
            ImGui.sameLine(100);
            ImGui.text(Std.string(mode));
     
            ImGui.endMenuBar();
        }

        //Scene image
        ImGui.image(sceneTex, {x : width, y : height});

        if(Std.isOfType(Inspector.currentInspectable, GameObject))
        {
            var go : GameObject = cast Inspector.currentInspectable;
            mousePos = ImGui.getMousePos();

            switch (mode)
            {
                case TRANSLATE :
                    handleTranslationGuizmo(go);
                case ROTATE :
                    handleRotationGuizmo(go);
                case SCALE :
                    handleScaleGuizmo(go);
            }

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

        //@:privateAccess camera.forcePosition(260, 120);
        //camera.zoom = 1.6;
    }

    public function centerScreenOn(x : Float, y : Float)
    {
        var windowOrigin : Vector2 = ImGui.getWindowPos() + windowOffset;
        @:privateAccess editor.sceneWindow.camera.forcePosition(x + sceneTex.width / 2, y + sceneTex.height / 2);
    }

    function updateControls(dt : Float)
    {
        //Camera
        mvt = avenyrh.Vector2.ZERO;

        if(hxd.Key.isDown(left))
            mvt.x = -1;
        if(hxd.Key.isDown(right))
            mvt.x = 1;
        if(hxd.Key.isDown(up))
            mvt.y = -1;
        if(hxd.Key.isDown(down))
            mvt.y = 1;

        if(hxd.Key.isPressed(hxd.Key.MOUSE_WHEEL_UP))
            camera.zoom += zoomSpeed;
        else if(hxd.Key.isPressed(hxd.Key.MOUSE_WHEEL_DOWN))
            camera.zoom -= zoomSpeed;

        mvt = mvt.normalize();
        camera.move(mvt.x * mvtSpeed / camera.zoom, mvt.y * mvtSpeed / camera.zoom);
        @:privateAccess camera.update(dt);
        @:privateAccess camera.postUpdate(dt);

        //Mode
        if(hxd.Key.isDown(translate))
            mode = TRANSLATE;
        if(hxd.Key.isDown(rotate))
            mode = ROTATE;
        if(hxd.Key.isDown(scale))
            mode = SCALE;
    }

    //--------------------
    //#region Private API
    //--------------------
    //Transform guizmo settings
    var lineThickness : Float = 4;
    var circleRadius : Float = 5;
    var axisLength : Float = 30;
    var xAxisColor : Int = Color.iBLUE;
    var yAxisColor : Int = Color.iGREEN;
    var circleColor : Int = Color.iWHITE;
    var highlightColor : Int = Color.iCYAN;

    var oldMousePos : Vector2 = Vector2.ZERO;
    var mousePos : Vector2 = Vector2.ZERO;
    var mouseClickedPos : Vector2 = Vector2.ZERO;
    var mouseClickedRot : Float = 0;
    var oldRotation : Float = 0;

    function handleTranslationGuizmo(go : GameObject)
    {
        //------ Draw guizmo ------
        var drawList : ImDrawList = ImGui.getForegroundDrawList();
        var windowOrigin : Vector2 = ImGui.getWindowPos() + windowOffset;
        var origin : Vector2 = windowOrigin + camera.worldToScreen(go.absX / camera.zoom, go.absY / camera.zoom);
        
        if(!isInScreenBounds(origin))
            return;

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

        //X axis
        drawList.addLine(origin, xEnd, operation.equals(TRANSLATE_X) ? highlightColor : xAxisColor, lineThickness);

        var p1 : Vector2 = xEnd + xLineOffset + Vector2.DOWN * 5;
        var p2 : Vector2 = xEnd + xLineOffset + Vector2.DOWN * -5;
        var p3 : Vector2 = xEnd + xLineOffset + Vector2.RIGHT * 6;
        drawList.addTriangleFilled(p1, p2, p3, operation.equals(TRANSLATE_X) ? highlightColor : xAxisColor);

        //Y axis
        drawList.addLine(origin + yLineOffset, yEnd + yLineOffset, operation.equals(TRANSLATE_Y) ? highlightColor : yAxisColor, lineThickness);

        var yTriangleOffset : Vector2 = Vector2.DOWN * -1;
        p1 = yEnd + yTriangleOffset + Vector2.RIGHT * -5;
        p2 = yEnd + yTriangleOffset + Vector2.RIGHT * 5;
        p3 = yEnd + yTriangleOffset + Vector2.DOWN * 6;
        drawList.addTriangleFilled(p1, p2, p3, operation.equals(TRANSLATE_Y) ? highlightColor : yAxisColor);

        //Center circle
        drawList.addCircleFilled(origin, circleRadius, operation.equals(TRANSLATE_XY) ? highlightColor : Color.iWHITE, 20);

        //------ Handle translation ------
        //Set current operation
        if(ImGui.isMouseClicked(0))
        {
            if(isInX)
                operation = TRANSLATE_X;
            else if(isInY)
                operation = TRANSLATE_Y;
            else if(isInCircle)
                operation = TRANSLATE_XY;
        }
        else if(ImGui.isMouseReleased(0))
            operation = NONE;

        //Move gameObject
        if(ImGui.isMouseDown(0))
        {
            //Mouse movement
            var deltaX : Float = (mousePos.x - oldMousePos.x) / camera.zoom;
            var deltaY : Float = (mousePos.y - oldMousePos.y) / camera.zoom;
            var pos : Vector2 = origin + new Vector2(deltaX, deltaY);

            if(operation.equals(TRANSLATE_X) && deltaX != 0 && isInScreenBounds(pos))
                go.move(deltaX, 0);
            else if(operation.equals(TRANSLATE_Y) && deltaY != 0 && isInScreenBounds(pos))
                go.move(0, deltaY);
            else if(operation.equals(TRANSLATE_XY) && (deltaX != 0 || deltaY != 0) && isInScreenBounds(pos))
                go.move(deltaX, deltaY);
        }
    }

    function handleRotationGuizmo(go : GameObject)
    {
        //------ Draw guizmo ------
        var drawList : ImDrawList = ImGui.getForegroundDrawList();
        var windowOrigin : Vector2 = ImGui.getWindowPos() + windowOffset;
        var origin : Vector2 = windowOrigin + camera.worldToScreen(go.absX / camera.zoom, go.absY / camera.zoom) + new Vector2(camera.x, camera.y);
        var radius : Float = 40;

        if(!isInScreenBounds(origin))
            return;

        //Outer circle
        drawList.addCircle(origin, radius, operation.equals(ROTATE) ? highlightColor : Color.iWHITE, 40, 2);

        //Horizontal line
        var p2 : Vector2 = !operation.equals(ROTATE) ? origin + Vector2.RIGHT * 40 :
            origin + new Vector2(40 * Math.cos(mouseClickedRot), -40 * Math.sin(mouseClickedRot));
        drawList.addLine(origin, p2, Color.iWHITE, 2);

        //Center circle
        drawList.addCircleFilled(origin, circleRadius, Color.iWHITE, 20);

        //------ Handle rotation ------
        var isInOuterCircle : Bool = isInsideCircle(origin, 43) && !isInsideCircle(origin, 37);
        
        //Set current operation
        if(ImGui.isMouseClicked(0) && isInOuterCircle)
        {
            operation = ROTATE;
            mouseClickedPos = ImGui.getMousePos();
            mouseClickedRot = AMath.getAngleBetween3Points(origin + Vector2.RIGHT, origin, mousePos);
            oldRotation = mouseClickedRot;
        }
        else if(ImGui.isMouseReleased(0))
            operation = NONE;

        //Rotate gameObject
        if(ImGui.isMouseDown(0) && operation.equals(ROTATE))
        {
            //Mouse movement
            var newRotation : Float = AMath.getAngleBetween3Points(origin + Vector2.RIGHT, origin, mousePos);
            var delta : Float = newRotation - oldRotation;

            if(delta != 0)
                go.rotate(delta);

            p2 = origin + new Vector2(40 * Math.cos(newRotation), -40 * Math.sin(newRotation));
            drawList.addLine(origin, p2, highlightColor, 2);

            oldRotation = newRotation;
        }
    }

    function handleScaleGuizmo(go : GameObject)
    {
        //------ Draw guizmo ------
        var drawList : ImDrawList = ImGui.getForegroundDrawList();
        var windowOrigin : Vector2 = ImGui.getWindowPos() + windowOffset;
        var origin : Vector2 = windowOrigin + camera.worldToScreen(go.absX / camera.zoom, go.absY / camera.zoom) + new Vector2(camera.x, camera.y);
        
        if(!isInScreenBounds(origin))
            return;

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

        //X axis
        drawList.addLine(origin, xEnd, operation.equals(SCALE_X) ? highlightColor : xAxisColor, lineThickness);

        var p1 : Vector2 = xEnd + xLineOffset + Vector2.DOWN * 4;
        var p2 : Vector2 = xEnd + xLineOffset + Vector2.DOWN * -4;
        var p3 : Vector2 = xEnd + xLineOffset + new Vector2(7, 4);
        var p4 : Vector2 = xEnd + xLineOffset + new Vector2(7, -4);
        drawList.addQuadFilled(p1, p2, p3, p4, operation.equals(SCALE_X) ? highlightColor : xAxisColor);

        //Y axis
        drawList.addLine(origin + yLineOffset, yEnd + yLineOffset, operation.equals(SCALE_Y) ? highlightColor : yAxisColor, lineThickness);

        var yTriangleOffset : Vector2 = Vector2.DOWN * -1;
        p1 = yEnd + yTriangleOffset + Vector2.RIGHT * -4;
        p2 = yEnd + yTriangleOffset + Vector2.RIGHT * 4;
        p3 = yEnd + yTriangleOffset + new Vector2(4, -7);
        p4 = yEnd + yTriangleOffset + new Vector2(-4, -7);
        drawList.addQuadFilled(p1, p2, p3, p4, operation.equals(SCALE_Y) ? highlightColor : yAxisColor);

        //Center circle
        drawList.addCircleFilled(origin, circleRadius, operation.equals(SCALE_XY) ? highlightColor : Color.iWHITE, 20);

        //------ Handle scaling ------
        //Set current operation
        if(ImGui.isMouseClicked(0))
        {
            if(isInX)
                operation = SCALE_X;
            else if(isInY)
                operation = SCALE_Y;
            else if(isInCircle)
                operation = SCALE_XY;
        }
        else if(ImGui.isMouseReleased(0))
            operation = NONE;

        //Scale gameObject
        if(ImGui.isMouseDown(0))
        {
            //Mouse movement
            var deltaX : Float = mousePos.x - oldMousePos.x;
            var deltaY : Float = mousePos.y - oldMousePos.y;
            
            if(operation.equals(SCALE_X) && deltaX != 0)
                go.scaleX += deltaX > 0 ? 0.1 : -0.1;
            else if(operation.equals(SCALE_Y) && deltaY != 0)
                go.scaleY += deltaY < 0 ? 0.1 : -0.1;
            else if(operation.equals(SCALE_XY) && (deltaX != 0 || deltaY != 0))
            {
                go.scaleX += deltaX > 0 ? 0.1 : -0.1;
                go.scaleY += deltaX > 0 ? 0.1 : -0.1;
            }
        }
    }

    function isInsideCircle(origin : Vector2, radius : Float) : Bool
    {
        var dist : Float = Math.sqrt(AMath.fdistSqr(origin.x, origin.y, mousePos.x, mousePos.y));
        
        return dist <= radius;
    }

    function isInScreenBounds(pos : Vector2) : Bool
    {
        var windowOrigin : Vector2 = ImGui.getWindowPos() + windowOffset;
        return pos.x >= windowOrigin.x && pos.x <= windowOrigin.x + sceneTex.width - 10 && 
            pos.y >= windowOrigin.y && pos.y <= windowOrigin.y + sceneTex.height;
    }
    //#endregion
}

enum TransformOperation
{
    NONE;
    TRANSLATE_X;
    TRANSLATE_Y;
    TRANSLATE_XY;
    ROTATE;
    SCALE_X;
    SCALE_Y;
    SCALE_XY;
}

enum TransformMode
{
    TRANSLATE;
    ROTATE;
    SCALE;
}