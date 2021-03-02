# About

Base framework for my games, using [**Heaps Game Engine**](https://heaps.io)


# Usage

The features present here are mostly inspired by [Deepnight's gamebase](https://github.com/deepnight/gameBase).
As I worked moslty with Unity, the framework here is similar in some points.


## Examples

In the examples folder, there are some examples on how to work with this framework :

- GameObjectScene : GameObject (controllable & fixed), Animator/Animation, Camera

- UIScene : Different UI components

- PFScene : AStar path finding algorithm (A to set start point, space to toggle simplifaction, r to reset, mouse left to set unwalkable, mouse right to reset to walkable)


## Base

- Boot is the entry point. It launches the avenyrh engine and adds the first scene

- Engine is what handles everything in the background and scene management

- Scene is where are all GameObjects and UI elements

- GameObject is an object with a Tile that can be placed in the Scene. It can have Components

- Component is where you will moslty write code for the gameplay and add it to one or more GameObjects


## Inspector

You have an Inspector that can help you to debug the game. Press F4 to show the Inspector window and click on the GameObject you want to inspect.
It shows different informations about the object, its components and its children.
You can put you own debug informations by overriding the `drawInspector` method.

Here is an example :
```haxe
public function drawInspector(inspector : Inspector, fold : Fold)
{
	//Two value field
    inspector.doubleField(fold, "left", () -> '${hxd.Math.fmt(value1)}', (v) -> value1 = Std.parseFloat(v), "right", () -> '${hxd.Math.fmt(value2)}', (v) -> value2 = Std.parseFloat(v));
	//On value field
    inspector.field(fold, "value", () -> variable.toString(), (v) -> variable = v);
	//Space
	inspector.space(fold, 20);
	//Text label
	inspector.textLabel(fold, "Label");
}
```

You have two buttons :
- Debug the bounds of all gameObjects
- Lock on the current gameObject


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


# Misc

Thanks to the Haxe and Heaps community for the help when creating this.
This is (and might always will be) a work in progress, so there might be some bugs, feel free to let me know.