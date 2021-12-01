# About

Base framework for my 2D games, using [**Heaps Game Engine**](https://heaps.io)


# Usage

The features present here are mostly inspired by [Deepnight's gamebase](https://github.com/deepnight/gameBase).
As I worked moslty with Unity, the framework here is similar in some points.


## Examples

In the examples folder, there are some examples on how to work with this framework :

- GameObjectScene : GameObject (controllable & fixed), Animator/Animation, Camera

- UIScene : Different UI components

- PFScene : AStar path finding algorithm (A to set start point, space to toggle simplifaction, r to reset, mouse left to set unwalkable, mouse right to reset to walkable)


## Base

- EntryPoint is the entry point. It launches the avenyrh engine and adds the first scene

- Engine is what handles everything in the background

- SceneManager handles scene management

- Scene is where are all GameObjects and UI elements

- GameObject is an object that can be placed in the Scene. It can have Components

- Component is where you will moslty write code for the gameplay and add it to one or more GameObjects


## Scene

Scene data is serialized in a file ```.scene``` and has all the data it needs to reconstruct your scene.
You have to implement ```SceneManagerData``` to tell the engine which scene you want in your game (look in the example file).
I haven't programmed a way to make new scene from the editor at the moment, I will be working on it soon.


## Editor

There is an editor to help you create and debug your game. To activate it, add ```-avenyrhEditor``` in your hxml.
You can put you own debug informations by overriding the `drawInfo` method.

Here is an example :
```haxe
public function drawInfo()
{
    //Don't forget the super call to append to already drawn informations
    //Get rid of this if you want to completely customize the display
    super.drawInfo();

    //Two floats/ints on the same line
    var array : Array<Float> = [x, y];
    Inspector.dragFloats("Array", uID, array, 0.1);
    x = array[0];
    y = array[1];
    
    //One int
    var v : Array<Int> = [value];
    Inspector.dragInts("Value", uID, v);
    value = v[0];

	//Enum field
    var i = Inspector.enumDropdown("Enum", uID, EnumName, currentEnumIndex);
    currentEnumIndex = haxe.EnumTools.createByIndex(EnumName, i);

	//Button
	if(Inspector.button("Foo", uID))
        foo();

	//Checkbox
	value = Inspector.checkbox("Value", uID, value);

	//Text
    Inspector.labelText("Text", uID, "Some text");

    //Tile
    Inspector.image("Tile", myTile);
}
```

There will be more wrapper in the future and I plan on making it simpler to use.
To have custom GameObject and Components show up in the editor, implement ```EditorData``` and complete the stringMaps (look in the example folder).


## UI
There are some UI components that can help with most of UI work :

- Button : Simple button with colors or custom graphics

- Checkbox : A true/false button

- Dropdown : List of items with one selected. Known bug : As this code is inspired by the Heaps h2d.Dropdown, it has the same bug where if the item is a h2d.Flow, it is not placed correctly

- ProgressBar : Parent class for all bars

	- SimpleBar : Horizontal or vertical progress bar. Ex -> Life or loading bar
	
	- PieBar : Circle progress bar. Ex -> Ability cooldown

- ScrollArea : Content window that can be scrolled both horizontaly and verticaly if the content is bigger that the window

- Tab : TabGroup handles TabButtons states and the corresponding content

- NineSlice : Cut a tile in 9 with corners, borders and a center container

You can Tween elements by addind tween to you objects.


## Others

- AMath is a maths library

- Color is a quick way to acces some basic colors

- Vector2 is a [x, y] representation

- Input config is where you can define some custom keybindings


## TO DO

- Have a way to create scene files

- Handle game UI in editor

- Sprite editor, to seperate sprites from a spritesheet

- Prefabs

- Animation rework and animation editor

- And a lot more


# Misc

Thanks to the Haxe and Heaps community for the help when creating this.
This is (and might always will be) a work in progress, so there might be some bugs, feel free to let me know.