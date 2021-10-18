package avenyrh.stateMachine;

class State
{
    /**
     * Unique ID used to set each state uID
     */
    static var UNIQ_ID = 0;

    /**
     * Unique ID of the state
     */
    public var uID (default, null) : Int;

    /**
     * StateMachine containing this tate
     */
    public var stateMachine (default, null) : StateMachine;

    /**
     * Name of the state
     */
    public var name (default, null) : String;

    /**
     * All transition going from this state
     */
    public var transitions (default, null) : Array<Transition>;

    /**
     * Is this state active and running
     */
    public var isActive (default, null) : Bool;
    
    /**
     * Is the gameObject destroyed
     */
    public var destroyed (default, null) : Bool;

    public function new(name : String, sm : StateMachine) 
    {
        uID = UNIQ_ID++;
        stateMachine = sm;
        this.name = name;
        transitions = [];
        isActive = false;
        destroyed = false;
    }

    //-------------------------------
    //#region Public API
    //-------------------------------
    /**
     * Adds a transition to this state
     * @param transition Transition going from this state
     */
    public function addTransition(transition : Transition)
    {
        if(transition.from != this)
            throw 'State ${name} : can not add transition that is not from this state | Wrong from state : ${transition.from}';
        else
        {
            transitions.push(transition);
            transitions.sort(function(a,b) return -Reflect.compare(a.priority, b.priority));
        }
    }

    /**
     * Removes a transtion
     * @param transition Transition to remove
     */
    public function removeTransition(transition : Transition)
    {
        if(!hasTransition(transition))
            return;

        transitions.remove(transition);
    }

    /**
     * Returns if the sate has this transistion
     * @param transition Transition to check
     * @return Return true if the state has the transition, false else
     */
    public function hasTransition(transition : Transition) : Bool 
    {
        if(transition == null)
            throw "Parameter can't be null";

        for(t in transitions)
            if(t.uID == transition.uID)
                return true;

        return false;
    }

    /**
     * Checks if a transition is true
     * @return Return the first valid transition, null if no valid one
     */
    public function checkTransitions() : Null<Transition>
    {
        for(i in 0...transitions.length)
        {
            if(transitions[i].condition())
                return transitions[i];
        }
        return null;
    }
    //#endregion

    //-------------------------------
    //#region Overridable functions
    //-------------------------------
    /**
     * Called when the state machine enters this state
     */
    public function onStateEnter(info : StateChangeInfo) { }

    /**
     * Called when the state machine update this state
     */
    public function onStateUpdate(dt : Float) { }

    /**
     * Called when the state machine exits this state
     */
    public function onStateExit(info : StateChangeInfo) { }

    /**
     * Called when beeing removed from the state machine
     */
    public function removed() { }
    //#endregion

    //-------------------------------
    //#region Private API
    //-------------------------------
    function _onStateEnter(info : StateChangeInfo) 
    {
        if(destroyed)
            return;

        isActive = true;

        onStateEnter(info);
    }

    function _onStateUpdate(dt : Float)
    {
        if(destroyed && !isActive)
            return;

        onStateUpdate(dt);
    }

    function _onStateExit(info : StateChangeInfo) 
    { 
        if(destroyed)
            return;

        isActive = false;

        onStateExit(info);
    }

    function _removed()
    {
        isActive = false;
        transitions = [];
        destroyed = true;

        removed();
    }
    //#endregion
}