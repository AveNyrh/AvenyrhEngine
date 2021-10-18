package avenyrh.stateMachine;

class StateChangeInfo
{
  public var previousState (default, null) : State;

  public var nextState (default, null) : State;
  
  public var transition (default, null) : Transition;

  public function new(ps : Null<State>, ns : State, t : Null<Transition>) 
  {
    previousState = ps;
    nextState = ns;
    transition = t;
  }
}