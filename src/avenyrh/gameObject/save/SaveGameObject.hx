package avenyrh.gameObject.save;

import avenyrh.engine.SaveLoader;

class SaveGameObject extends GameObject implements ISaveable
{
    public var saveID : String;

    override function init() 
    {
        super.init();

        saveID = name;
        SaveLoader.SAVEABLES.push(this);
    }

    override function onDestroy() 
    {
        super.onDestroy();

        SaveLoader.SAVEABLES.remove(this);
    }

    //--------------------
    //Overridable functions
    //--------------------
    /**
     * Override this to save data from this game object
     * @return SaveData Data you want to save
     */
    public function CaptureState() : SaveData { return null; }

    /**
     * Override this to restore saved data to this game object
     * @param saveData Saved data to restore
     */
    public function RestoreState(saveData : SaveData) { }

    //--------------------
    //Private API
    //-------------------- 
    /**
     * Gets all save data from every save component on this game object
     */
    function getComponentsData() : Map<String, Dynamic>
    {
        var stateMap : Map<String, Dynamic> = new Map<String, Dynamic>();
        
        for(c in getComponents(SaveComponent))
        {
            if(!stateMap.exists(c.saveID))
                stateMap.set(c.saveID, c.CaptureState());
        }

        return stateMap;
    }

    /**
     * Restores all saved data to all save components
     */
    function restoreComponentsData(stateMap : Map<String, Dynamic>)
    {
        for(c in getComponents(SaveComponent))
        {
            if(stateMap.exists(c.saveID))
               c.RestroreState(stateMap[c.saveID]); 
        }
    }
}