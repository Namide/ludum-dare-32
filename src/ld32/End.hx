package ld32;
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
		
		/*body = new Body(BodyType.STATIC);
		body.userData.name = "end";
		body.allowRotation = false;
		body.shapes.add(new Polygon(Polygon.rect( -s * 0.5, -s * 0.5, s, s)));
		body.position.setxy( ui.x, ui.y );*/
		
		display = ui;//new SpykesUI();
	}
	
}