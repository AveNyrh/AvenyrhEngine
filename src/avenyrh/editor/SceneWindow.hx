package avenyrh.editor;

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
}