package avenyrh.editor;

import haxe.ds.StringMap;

/**
 * When implementing this, import all custom components, DCE will remove the class if not
 */
interface IEditorData 
{ 

   /**
    * Array of all components to be included
    */
   var gameObjects (default, null) : StringMap<Class<Dynamic>>;

   /**
    * Array of all components to be included
    */
   var components (default, null) : StringMap<Class<Dynamic>>;
}