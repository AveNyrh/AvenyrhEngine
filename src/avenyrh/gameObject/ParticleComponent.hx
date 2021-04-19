package avenyrh.gameObject;

import avenyrh.engine.Inspector;
import avenyrh.ui.Fold;
import h2d.Particles;

class ParticleComponent extends Component
{
    var particles : Particles;

    var group : ParticleGroup;

    override public function new(gameObject : GameObject, name : String) 
    {
        super(gameObject, name);

        particles = new Particles(gameObject);
		group = new ParticleGroup(particles);

        //Tile animation ?
        //Save/load on a file by path name
    }

    override function drawInfo(inspector : Inspector, fold : Fold) 
    {
        super.drawInfo(inspector, fold);

        //size
        //sizeRand
		//gravity
		//life
		//speed
		//speedRand
	    //emitMode
		//emitDist
		//emitAngle
        //fadeIn
		//fadeOut
    }
}