package avenyrh.engine;

@:allow(avenyrh.engine.Engine)
interface IGarbageCollectable 
{
    private function onDispose() : Void;    
}