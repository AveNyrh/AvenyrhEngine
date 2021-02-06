package examples.src;

import avenyrh.InputManager;
import avenyrh.stateMachine.Transition;
import avenyrh.animation.Animation;
import avenyrh.animation.Animator;

class SimpleAnimator extends Animator
{
    override function init() 
    {
        super.init();

        var a1 : Animation = addAnimation(new SimpleAnimation("TestAnimation", stateMachine, this, true));
        var a2 : Animation = addAnimation(new SimpleAnimation2("TestAnimation2", stateMachine, this, true));
        new Transition(a1, a2, () -> InputManager.getKeyDown("Jump"));
        new Transition(a2, a1, () -> InputManager.getKeyDown("Jump"));
    }
}