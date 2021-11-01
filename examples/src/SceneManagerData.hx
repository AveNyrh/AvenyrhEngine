package examples.src;

import avenyrh.scene.ISceneManagerData;

//Import custom scenes
import examples.src.TestScene;

class SceneManagerData implements ISceneManagerData
{
    public var scenesFolderPath : String = "examples/res/scenes/";

    public var scenes : Array<String> = 
    [
        "TestScene"
    ];

    public function new() { }
}