package avenyrh.gameObject.save;

class SaveComponent extends Component
{
    public var saveID (default, null) : String;

    override function init() 
    {
        super.init();

        saveID = '${gameObject.name}_${name}';
    }

    //--------------------
    //Overridable functions
    //--------------------
    /**
     * Override this to save data from this component
     * @return Dynamic Data you want to save
     */
    public function CaptureState() : Dynamic { return null; }

    /**
     * Override this to restore saved data to this component
     * @param state Saved data to restore
     */
    public function RestroreState(state : Dynamic) { }
}