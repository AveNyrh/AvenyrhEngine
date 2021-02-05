package avenyrh.engine;

import avenyrh.gameObject.save.SaveData;
import avenyrh.gameObject.save.ISaveable;

class SaveProcess extends Process implements ISaveable
{
    public var saveID : String;

    override function init() 
    {
        super.init();

        saveID = name;
        SaveLoader.SAVEABLES.push(this);
    }

    override function onDispose() 
    {
        super.onDispose();

        SaveLoader.SAVEABLES.remove(this);
    }

    //--------------------
    //Overridable functions
    //--------------------
    /**
     * Override this to save data from this process
     * @return SaveData Data you want to save
     */
    public function CaptureState() : SaveData { return null; }

     /**
      * Override this to restore saved data to this process
      * @param saveData Saved data to restore
      */
    public function RestoreState(saveData : SaveData) { }
}