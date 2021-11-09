package examples.src;

import haxe.ds.StringMap;
import avenyrh.editor.IEditorData;

//Import curtom components
import examples.src.TestComponent;

class EditorData implements IEditorData
{
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