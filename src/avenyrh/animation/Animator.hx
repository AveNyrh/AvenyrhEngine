package avenyrh.animation;

import avenyrh.gameObject.Component;
import avenyrh.stateMachine.*;

class Animator extends Component
{
    var variables : Map<String, Any>;
    var stateMachine : StateMachine;

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

    override function getInfo() : String 
    {
        var s : String = super.getInfo();
        s += stateMachine.currentState.name + "\n";
        return s;
    }

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
}