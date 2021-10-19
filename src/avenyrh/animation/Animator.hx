package avenyrh.animation;

import avenyrh.imgui.ImGui;
import avenyrh.editor.Inspector;
import avenyrh.gameObject.Component;
import avenyrh.stateMachine.*;

class Animator extends Component
{
    var variables : Map<String, Any>;

    public var stateMachine : StateMachine;

    public var play : Bool;

    //-------------------------------
    //#region Private API
    //-------------------------------
    override function init() 
    {
        super.init();

        variables = new Map<String, Any>();
        stateMachine = new StateMachine(name + " State Machine");
        play = true;
    }

    override function start() 
    {
        super.start();

        stateMachine.start();
    }

    override function postUpdate(dt : Float) 
    {
        super.postUpdate(dt);

        if(play)
            stateMachine.update(dt);
    }

    override function drawInfo() 
    {
        super.drawInfo();

        play = Inspector.checkbox("Play", uID, play);
        Inspector.labelText("Animation", uID, stateMachine.currentState.name);

        var anim : Animation = cast stateMachine.currentState;
        var sliderV = new hl.NativeArray<Single>(1);
        sliderV[0] = anim.currentTime;

        if(ImGui.sliderFloat('Time###Time$uID', sliderV, 0, anim.length, "%.4f"))
            anim.setCurrentTime(sliderV[0]);
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