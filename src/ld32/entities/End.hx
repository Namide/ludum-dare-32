package ld32.entities;
import flash.display.DisplayObject;
import nape.phys.Body;
import nape.phys.BodyType;
import nape.shape.Polygon;

/**
 * ...
 * @author Namide (Damien Doussaud)
 */
class End extends Entity
{

	public function new( ui:DisplayObject ) 
	{
		super();
		
		var s = 32;
		var dir = 1;
		
		if ( Std.is( ui, End64UI ) )
		{
			s = 64;
		}
		
		display = ui;
	}
	
}