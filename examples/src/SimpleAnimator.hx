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
        new Transition(a1, a2, () -> hxd.Key.isPressed(hxd.Key.SPACE));
        new Transition(a2, a1, () -> hxd.Key.isPressed(hxd.Key.SPACE));
    }
}