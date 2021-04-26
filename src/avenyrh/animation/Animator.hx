package avenyrh.animation;

import avenyrh.imgui.ImGui;
import avenyrh.engine.Inspector;
import avenyrh.ui.Fold;
import avenyrh.gameObject.Component;
import avenyrh.stateMachine.*;

class Animator extends Component
{
    var variables : Map<String, Any>;
    public var stateMachine : StateMachine;

    //-------------------------------
    //#region Private API
    //-------------------------------
    override function init() 
    {
        super.init();

        variables = new Map<String, Any>();
        stateMachine = new StateMachine(name + " State Machine");
    }

    override function start() 
    {
        super.start();

        stateMachine.start();
    }

    override function postUpdate(dt : Float) 
    {
        super.postUpdate(dt);

        stateMachine.update(dt);
    }

    override function drawInfo() 
    {
        super.drawInfo();

        Inspector.labelText("Animation", uID, stateMachine.currentState.name);
    }
    //#endregion

    //-------------------------------
    //#region Public API
    //-------------------------------
    /**
     * Adds an animation to the state machine
     * @param animation Animation to add
     * @param isDefault Is default animation ?
     */
    public function addAnimation(animation : Animation, ?isDefault : Bool = false) : Animation
    {
        stateMachine.addState(animation, isDefault);

        return animation;
    }

    public function addVariable(name : String, value : Any)
    {
        if(variables.exists(name))
            return;

        variables.set(name, value);
    }

    public function updateVariable(name : String, value : Any) 
    {
        if(!variables.exists(name))
            return;
        
        variables.set(name, value);
    }
    //#endregion
}