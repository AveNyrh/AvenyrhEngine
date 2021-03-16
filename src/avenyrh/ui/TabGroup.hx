package avenyrh.ui;

import h2d.Object;
import h2d.Flow;

class TabGroup extends Flow
{
    /**
     * All the buttons and the tabs
     */
    var buttons : Map<TabButton, Object>;
    /**
     * Container for the buttons
     */
    public var buttonsFlow : Flow;
    /**
     * The current selected button
     */
    public var selectedButton (default, null) : TabButton;
    /**
     * Default button to be selected when opening the tab group \
     * Can be null 
     */
    public var defaultSelectedButton : Null<TabButton>;

    public function new(parent : Object) 
    {
        super(parent);

        buttons = new Map<TabButton, Object>();
        selectedButton = null;
        defaultSelectedButton = null;

        buttonsFlow = new Flow(this);
    }

    //-------------------------------
    //#region Public API
    //-------------------------------
    /**
     * Opens the tab \
     * Opens the defaultSelectedButton tab if not null, else the last selected
     */
    public function openTab() 
    {
        visible = true;

        resetTabs();
        
        if(defaultSelectedButton != null)
            selectedButton = defaultSelectedButton;

        defaultSelectedButton.visible = true;
        @:privateAccess defaultSelectedButton.isSelected = true;
    }

    /**
     * Closes the tab
     */
    public function closeTab() 
    {
        visible = false;
        
        resetTabs();
        buttons[selectedButton].visible = false;
    }

    /**
     * Adds a button to the tab group, the object is the object that gets enable/disable by the tab
     */
    public function addButton(button : TabButton, object : Object) 
    {
        if(!buttons.exists(button))
        {
            buttons.set(button, object); 

            if(selectedButton == null)
                selectedButton = button;
            else 
                object.visible = false;
        }
    }

    /**
     * Removes a button from the tab group
     */
    public function removeButton(button : TabButton) 
    {
        if(buttons.exists(button))
            buttons.remove(button);    
    }
    //#endregion

    //-------------------------------
    //#region Private API
    //-------------------------------
    /**
     * Called by a button when it gets selected
     */
    function onTabSelected(button : TabButton) 
    {
        if(selectedButton != null)
            @:privateAccess selectedButton.isSelected = false;

        selectedButton = button;

        resetTabs();

        buttons[button].visible = true;
        @:privateAccess button.isSelected = true;
    }

    /**
     * Closes all tabs exept the selected one
     */
    function resetTabs() 
    {
        if(selectedButton != null)
            @:privateAccess selectedButton.isSelected = false;

        for (b in buttons.keys())
        {
            if(b != selectedButton)
                buttons[b].visible = false;
        }
    }
    //#endregion
}