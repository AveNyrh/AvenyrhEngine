package examples.src;

import avenyrh.stateMachine.Transition;
import avenyrh.animation.Animation;
import avenyrh.animation.Animator;

class SimpleAnimator extends Animator
{
    override function init() 
    {
        super.init();

        var a1 : Animation = addAnimation(new SimpleAnimation("TestAnimation", this, true));
        var a2 : Animation = addAnimation(new SimpleAnimation2("TestAnimation2", this, true));
        
        new Transition(a1, a2, () -> hxd.Key.isPressed(hxd.Key.NUMBER_2));
        new Transition(a2, a1, () -> hxd.Key.isPressed(hxd.Key.NUMBER_1));
    }
}