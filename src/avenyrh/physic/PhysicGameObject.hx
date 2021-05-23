package avenyrh.physic;

import avenyrh.gameObject.GameObject;
import avenyrh.imgui.ImGui;
import avenyrh.engine.Inspector;
import avenyrh.engine.SaveLoader;
import echo.data.Options.BodyOptions;
import echo.data.Types.ShapeType;
import haxe.ds.StringMap;
import echo.Body;
import echo.World;
import h2d.Object;

class PhysicGameObject extends GameObject
{
    static var data : StringMap<ColliderOptions>;

    public var body : Body;

    public var offset : ColliderOffset;

    var inspectorInfo : InspectorInfo;

    override public function new(name : String, parent : Object, world : World, colType : ColliderType) 
    {
        super(name, parent);

        offset = new ColliderOffset();

        body = new Body(getBodyOptions(colType, world));

        world.add(body);
    }

    override function start() 
    {
        super.start();

        body.x = x + offset.x;
        body.y = y + offset.y;
        body.rotation = AMath.toDeg(rotation) + offset.rotation;
        body.scale_x = scaleX * offset.scaleX;
        body.scale_y = scaleY * offset.scaleY;
    }

    override function update(dt : Float) 
    {
        super.update(dt);

        if(body.active)
        {
            x = body.x - offset.x;
            y = body.y - offset.y;
        }
    }

    override function drawInspector()
    {
        inspectorInfo = 
        {
            x : this.x,
            y : this.y,
            rot : rotation,
            sX : scaleX,
            sY : scaleY,
            changed : false
        };

        super.drawInspector();
    }

    override function drawInfo() 
    {
        super.drawInfo();

        if(inspectorInfo.x != x || inspectorInfo.y != y || inspectorInfo.rot != rotation || inspectorInfo.sX != scaleX || inspectorInfo.sY != scaleY)
            inspectorInfo.changed = true;

        ImGui.spacing();

        var flags : ImGuiTreeNodeFlags = DefaultOpen;

        if(ImGui.treeNodeEx("Physic", flags))
        {

            if(Inspector.button("Save", uID))
                saveCollider();

            //body.x/y : Float
            var pos : Array<Float> = [offset.x, offset.y];
            if(Inspector.dragFields("Pos offset", uID, pos, 0.1))
            {
                offset.x = pos[0];
                offset.y = pos[1];
            }

            //body.rotation : Float
            var r : Array<Float> = [offset.rotation];
            if(Inspector.dragFields("Rot offset", uID, r, 0.1))
                offset.rotation = r[0];

            //body.scale_x/y : Float
            var sc : Array<Float> = [offset.scaleX, offset.scaleY];
            if(Inspector.dragFields("Scale offset", uID, sc, 0.1))
            {
                offset.scaleX = sc[0];
                offset.scaleY = sc[1];
            }

            //body.mass : Float
            var m : Array<Float> = [body.mass];
            if(Inspector.dragFields("Mass", uID, m, 0.1))
                body.mass = m[0];

            //body.gravity_scale : Float
            var gs : Array<Float> = [body.gravity_scale];
            if(Inspector.dragFields("Gravity scale", uID, gs, 0.1))
                body.gravity_scale = gs[0];

            //body.elasticity : Float
            var e : Array<Float> = [body.elasticity];
            if(Inspector.dragFields("Elasticity", uID, e, 0.1))
                body.elasticity = e[0];

            //body.velocity : Vector2
            var v : Array<Float> = [body.velocity.x, body.velocity.y];
            if(Inspector.dragFields("Velocity", uID, v, 0.1))
            {
                body.velocity.x = v[0];
                body.velocity.y = v[1];
            }

            //body.acceleration : Vector2
            var acc : Array<Float> = [body.acceleration.x, body.acceleration.y];
            if(Inspector.dragFields("Acceleration", uID, acc, 0.1))
            {
                body.acceleration.x = acc[0];
                body.acceleration.y = acc[1];
            }

            //body.drag : Vector2
            var d : Array<Float> = [body.drag.x, body.drag.y];
            if(Inspector.dragFields("Drag", uID, d, 0.1))
            {
                body.drag.x = d[0];
                body.drag.y = d[1];
            }

            //body.active : Bool
            var a : Bool = Inspector.checkbox("Active", uID, body.active);
            if(body.active != a)
                body.active = a;

            //body.kinematic : Bool
            var k : Bool = Inspector.checkbox("Kinematic", uID, body.kinematic);
            if(body.kinematic != k)
                body.kinematic = k;

            ImGui.treePop();
        }

        //-------------------------------

        if(inspectorInfo.changed)
        {
            if(body.x != x + offset.x)
                body.x = x + offset.x;
            
            if(body.y != y + offset.y)
                body.y = y + offset.y;

            if(body.rotation != AMath.toDeg(rotation) + offset.rotation)
                body.rotation = AMath.toDeg(rotation) + offset.rotation;

            if(body.scale_x != scaleX * offset.scaleX)
                body.scale_x = scaleX * offset.scaleX;

            if(body.scale_y != scaleY * offset.scaleY)
                body.scale_y = scaleY * offset.scaleY;

            body.velocity = new hxmath.math.Vector2(0, 0);
        }
    }

    override function setPosition(x : Float, y : Float) 
    {
        super.setPosition(x, y);

        if(posChanged)
        {
            body.set_position(x + offset.x, y + offset.y);
            body.rotation = rotation + offset.rotation;
            body.scale_x = scaleX * offset.scaleX;
            body.scale_y = scaleY * offset.scaleY;
        }
    }

    function getBodyOptions(type : ColliderType, world : World) : BodyOptions
    {
        switch(type)
        {
            case Circle :
                return
                {
                    x : x,
                    y : y,
                    scale_x : scaleX,
                    scale_y : scaleY, 
                    shape : 
                    {
                        type : ShapeType.CIRCLE,
                        radius : 10,
                    },
                };
            case Rect :
                return
                {
                    x : x,
                    y : y,
                    rotation : rotation,
                    scale_x : scaleX,
                    scale_y : scaleY,
                    shape : 
                    {
                        type : ShapeType.RECT,
                        width : 10,
                        height : 10,
                    },
                }
            case Capsule :
                return
                {
                    x : x,
                    y : y,
                    rotation : rotation,
                    scale_x : scaleX,
                    scale_y : scaleY,
                    shapes : 
                    {
                        [
                            {
                                type : ShapeType.RECT,
                                width : 10,
                                height : 10,
                            },
                            {
                                type : ShapeType.CIRCLE,
                                radius : 5,
                                offset_x : 0,
                                offset_y : 5, 
                            },
                            {
                                type : ShapeType.CIRCLE,
                                radius : 5,
                                offset_x : 0,
                                offset_y : -5, 
                            }
                        ];
                    }
                }
            case Polygone :
                return
                {
                    x : x,
                    y : y,
                    rotation : rotation,
                    scale_x : scaleX,
                    scale_y : scaleY,
                    shape : 
                    {
                        type : ShapeType.POLYGON,
                        radius : 10, 
                        width : 10,
                        height : 10,
                        sides : 5,
                    },
                }
            default :
                return null;
        }
    }

    //-------------------------------
    //#region Public API
    //-------------------------------
    /**
     * Saves collider in the res/sav/colliders.sav file
     */
    public function saveCollider()
    {
        var co : ColliderOptions = new ColliderOptions();

        co.x = offset.x;
        co.y = offset.y;
        co.rotation = offset.rotation;
        co.scaleX = offset.scaleX;
        co.scaleY = offset.scaleY;
        co.mass = body.mass;
        co.gravityScale = body.gravity_scale;
        co.elasticity = body.elasticity;
        co.dragX = body.drag.x;
        co.dragY = body.drag.y;
        co.active = body.active;
        co.kinematic = body.kinematic;

        data.set(name, co);
        saveData();
    }

    /**
     * Loads collider options
     */
    public function loadCollider()
    {
        if(!data.exists(name))
            return;

        var co : ColliderOptions = data.get(name);

        offset.x = co.x;
        offset.y = co.y;
        offset.rotation = co.rotation;
        offset.scaleX = co.scaleX;
        offset.scaleY = co.scaleY;
        body.mass = co.mass;
        body.gravity_scale = co.gravityScale;
        body.elasticity = co.elasticity;
        body.drag = new hxmath.math.Vector2(co.dragX, co.dragY);
        body.active = co.active;
        body.kinematic = co.kinematic;
    }
    //#endregion

    //-------------------------------
    //#region Static API
    //-------------------------------
    static function initData()
    {
        // data = new StringMap<ColliderOptions>();
        // var obj : Dynamic = Unserializer.run(hxd.Res.sav.colliders.entry.getBytes().toString());
        // data = cast obj;
    }
    
    static function saveData()
    {
        SaveLoader.saveData("colliders", data);
    }
    //#endregion
}

enum ColliderType
{
    Circle;
    Rect;
    Polygone;
    Capsule;
    Other;
}

class ColliderOffset
{
    public var x : Float;

    public var y : Float;

    public var rotation : Float;

    public var scaleX : Float;

    public var scaleY : Float;

    public function new()
    {
        x = 0;
        y = 0;
        rotation = 0;
        scaleX = 1;
        scaleY = 1;
    }
}

class ColliderOptions 
{
    public var x : Float;

    public var y : Float;

    public var rotation : Float;

    public var scaleX : Float;

    public var scaleY : Float;
    
    public var mass : Float;

    public var gravityScale : Float;

    public var elasticity : Float;

    public var dragX : Float;
    
    public var dragY : Float;

    public var active : Bool;

    public var kinematic : Bool;

    public function new() { }
}

typedef InspectorInfo =
{
    var x : Float;
    var y : Float;
    var rot : Float;
    var sX : Float;
    var sY : Float;
    var changed : Bool;
}