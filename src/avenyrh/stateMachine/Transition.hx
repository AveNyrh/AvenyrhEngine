package avenyrh.stateMachine;

class Transition 
{
    /**
     * Unique ID used to set each transition uID
     */
    static var UNIQ_ID = 0;

    /**
     * Unique ID of the transition
     */
    public var uID (default, null) : Int;

    /**
     * State from where this transition begins
     */
    public var from (default, null) : State;

    /**
     * State to where this transition goes
     */
    public var to (default, null) : State;

    /**
     * Condition function to set this transition active
     */
    public var condition (default, null) : Void -> Bool;
    
    /**
     * Priority of the transition when checking
     */
    public var priority (default, null) : Int;

    public function new(from : State, to : State, condition : Void -> Bool, ?priority : Int = 0) 
    {
        uID = UNIQ_ID++;
        this.from = from;
        this.to = to;
        this.condition = condition;
        this.priority = priority;

        from.addTransition(this);
    }
}