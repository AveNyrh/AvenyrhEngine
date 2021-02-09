package avenyrh.stateMachine;

import avenyrh.engine.IGarbageCollectable;
import avenyrh.engine.Engine;

class StateMachine implements IGarbageCollectable
{
    /**
     * Unique ID used to set each stateMachine uID
     */
    static var UNIQ_ID = 0;

    /**
      * Unique ID of the stateMachine
      */
    public var uID (default, null) : Int;
    /**
      * Name of the stateMachine
      */
    public var name (default, null) : String;
    /**
     * Is this state active and running
     */
    public var isActive (default, null) : Bool;
    /**
     * All states in the stateMachine
     */
    public var states (default, null) : Array<State>;
    /**
     * Current active state
     */
    public var currentState (default, null) : State;
    /**
     * The default state of the stateMachine
     */
    public var defaultState (default, null) : State;
    /**
     * State Any, put transition with this state to be checked each frame
     */
    public var anyState : State;
    /**
      * Is the gameObject destroyed
      */
    public var destroyed (default, null) : Bool;

    public function new(name : String) 
    {
      uID = UNIQ_ID++;
      this.name = name;
      destroyed = false;
      states = [];
      anyState = new State("Any", this);
    }

    //-------------------------------
    //#region Public API
    //-------------------------------
    public function start()
    {
      if(states.length == 0)
        throw 'There are no states in ${name}';
      if(defaultState == null)
        throw 'There is no default state in ${name}';

      isActive = true;
      var info = new StateChangeInfo(null, defaultState, null);
      defaultState.onStateEnter(info);
      currentState = defaultState;
    }

    public function update(?dt : Float = 0) 
    {
      if(!isActive || destroyed)
        return;

      //First check transition with the current state
      var t = currentState.checkTransitions();

      //Check transition with Any if no transition was found on the current
      if(t == null)
        t = anyState.checkTransitions();

      if(t == null)
      {
        //No transition valid, just update
        @:privateAccess currentState._onStateUpdate(dt);
      }
      else
      {
        //Transition to a new state
        var previous = currentState;
        var next = t.to;
        var info = new StateChangeInfo(previous, next, t);

        @:privateAccess currentState._onStateExit(info);
        @:privateAccess next._onStateEnter(info);
        currentState = next;
      }
    }

    public function addState(state : State, ?isDefault : Bool = false)
    {
      states.push(state);

      if(isDefault || defaultState == null)
        defaultState = state;
    }

    public function setDefaultState(state : State)
    {
      if(!hasState(state))
        throw '${name} does not have this state ${state.name}, can not set it to default';

      defaultState = state;
    }

    /**
     * Returns if the sateMachine has this state
     * @param state State to check
     * @return Return true if the stateMachine has the state, false else
     */
    public function hasState(state : State) : Bool 
    {
      if(state == null)
        throw "Parameter can't be null";

      for(s in states)
        if(s.uID == state.uID)
          return true;
  
      return false;
    }

    public function removed()
    {
      isActive = false;

      for(s in states)
        s.removed();

      Engine.instance.gc.push(this);
    }
    //#endregion
    
    /**
     * GarbageCollectable implementation \
     * Destroys this stateMachine and removes the states
     */
    public function onDispose()
    {
      destroyed = true;
      states = [];
    }
}