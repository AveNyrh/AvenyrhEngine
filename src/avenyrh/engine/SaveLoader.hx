package avenyrh.engine;

import hxd.Save;
import haxe.ds.StringMap;
import avenyrh.gameObject.save.SaveData;
import avenyrh.gameObject.save.ISaveable;

class SaveLoader 
{
    public static var SAVEABLES : Array<ISaveable>;

    /**
     * Saves all ISaveable registered in SAVEABLES to the path
     */
    public static function save(path : String) 
    {
        var data : StringMap<SaveData> = new StringMap<SaveData>();

        for(s in SAVEABLES)
            data.set(s.saveID, s.CaptureState());

        Save.save(data, path);
    }

    /**
     * Saves the data to the path
     */
    public static function saveData(path : String, data : Dynamic) 
    {
        Save.save(data, path);
    }

    /**
     * Loads data from path and restores it to all ISaveable in SAVEABLES
     */
    public static function load(path : String) 
    {
        var data : StringMap<SaveData> = new StringMap<SaveData>();
        
        data = Save.load(data, path);

        for(s in SAVEABLES)
        {
            if(data.exists(s.saveID))
                s.RestoreState(data.get(s.saveID));
        }
    }

    /**
     * Loads data from path and returns it
     */
    public static function loadData<T>(path : String, defaultValue : Null<T>) : Null<T> 
    {
        var data : T;
        
        data = Save.load(defaultValue, path);

        return data;
    }

    /**
     * Delete the save file at the path
     */
    public static function delete(path : String)
    {
        Save.delete(path);
    }
}