package ld32;
import flash.display.DisplayObject;
import nape.phys.Body;
import nape.phys.BodyType;
import nape.shape.Circle;

/**
 * ...
 * @author Namide (Damien Doussaud)
 */
class Spikes extends Entity
{

	public var angularVel:Float;
	
	public function new( ui:DisplayObject ) 
	{
		super();
		
		var s = 32;
		var dir = (Math.random()>0.5) ? 1 : -1;
		var v = 4;
		
		if ( Std.is( ui, Spikeball32UI ) )
		{
			s = 32;
		}
		else if ( Std.is( ui, Spikeball64UI ) )
		{
			s = 64;
		}
		else if ( Std.is( ui, Spikeball32SpeedUI ) )
		{
			s = 32;
			v *= 2;
		} 
		
		
		r = s * 0.5;
		
		body = new Body(BodyType.DYNAMIC);
		body.userData.name = "spikes";
		//box.allowRotation = false;
		body.shapes.add(new Circle(s * 0.5));
		body.position.setxy( ui.x, ui.y );
		this.angularVel = body.angularVel = v * dir;
		//box.space = SPACE;
		
		display = ui;//new SpykesUI();
	}
	
	override public function upd(t:Float) 
	{
		body.angularVel = angularVel;
		super.upd(t);
	}
	
}