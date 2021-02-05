package avenyrh.gameObject.save;

import avenyrh.gameObject.save.SaveData;

interface ISaveable 
{
    /**
     * Unique identifier
     */
    var saveID : String;
    /**
     * Captures the current state for it to be saved
     */
    function CaptureState() : SaveData;

    /**
     * Gives a state to restore and load previous values
     */
    function RestoreState(saveData : SaveData) : Void;
}