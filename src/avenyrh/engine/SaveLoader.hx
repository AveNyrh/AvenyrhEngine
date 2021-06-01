package avenyrh.engine;

import hxd.Save;

class SaveLoader 
{
    //-------------------------------
    //#region Public static API
    //-------------------------------
    /**
     * Saves the data to the path
     */
    public static function saveData(path : String, data : Dynamic) 
    {
        Save.save(data, path);
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
    //#endregion
}