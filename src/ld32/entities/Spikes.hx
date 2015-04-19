package ld32.entities;
import flash.display.DisplayObject;
import ld32.entities.Entity;
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
		
		var s = 32.0;
		var dir = (Math.random()>0.5) ? 1 : -1;
		var v = 4.0;
		
		if ( Std.is( ui, Spikeball32UI ) )
		{
			s = 32;
		}
		else if ( Std.is( ui, Spikeball64UI ) )
		{
			s = 64;
		}
		else if ( Std.is( ui, Spikeball128UI ) )
		{
			s = 128;
			v *= 1.5;
		}
		else if ( Std.is( ui, Spikeball32SpeedUI ) )
		{
			s = 32;
			v *= 2;
		} 
		
		
		r = s * 0.5;
		
		body = new Body(BodyType.DYNAMIC);
		body.userData.name = "spikes";
		body.shapes.add(new Circle(s * 0.5));
		body.position.setxy( ui.x, ui.y );
		this.angularVel = body.angularVel = v * dir;
		
		display = ui;
	}
	
	override public function upd(t:Float) 
	{
		body.angularVel = angularVel;
		super.upd(t);
	}
	
}