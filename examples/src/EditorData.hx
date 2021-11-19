package examples.src;

import haxe.ds.StringMap;
import avenyrh.editor.IEditorData;

//Import custom processes
import avenyrh.Camera;

//Import custom gameObjects
import examples.src.ControllableGameObject;
import examples.src.FixedGameObject;

//Import custom components
import examples.src.TestComponent;

class EditorData implements IEditorData
{
    public var processes : StringMap<Class<Dynamic>> = 
    [
        "Camera" => Camera,
    ];

    public var gameObjects : StringMap<Class<Dynamic>> = 
    [
        "ControllableGamObject" => ControllableGameObject,
        "FixedGameObject" => FixedGameObject
    ];

    public var components : StringMap<Class<Dynamic>> = 
    [
        "TestComponent" => TestComponent
    ];

    public function new() { }
}