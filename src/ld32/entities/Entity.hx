package ld32.entities;
import flash.display.DisplayObject;
import ld32.manager.PhysicManager;
import nape.callbacks.CbEvent;
import nape.callbacks.CbType;
import nape.callbacks.InteractionCallback;
import nape.callbacks.InteractionListener;
import nape.callbacks.InteractionType;
import nape.dynamics.Arbiter;
import nape.geom.Vec2;
import nape.phys.Body;
import nape.phys.Interactor;

/**
 * ...
 * @author Namide (Damien Doussaud)
 */
class Entity
{
	public static inline var PI = 3.14159265358979323;
	public static inline var QUART_PI = PI / 4;
	public static inline var HALF_PI = PI / 2;
	public static inline var DOUBLE_PI = PI * 2;
	public static inline var RAD_TO_DEGREES = 180 / PI;
	
	public var inWorld:Bool;
	
	public var display:DisplayObject;
	public var body:Body;
	public var r:Float;
	
	public function new() 
	{
		inWorld = true;
	}
	
	public function upd( t:Float )
	{
		if ( body != null && body.space != null && !body.isSleeping )
		{
			display.x = body.position.x;
			display.y = body.position.y;
			display.rotation = body.rotation * RAD_TO_DEGREES;
		}
	}
	
	public static function getContacts( body:Body )
	{
		var contacts = { left:false, right:false, bottom:false, top:false };
		
		if ( body.arbiters.length > 0 )
			for ( a in body.arbiters )
				isOver( a, contacts );
		
		return contacts;
	}
	
	public inline function hitTest( e:Entity )
	{
		return Vec2.get( display.x, display.y ).sub( Vec2.get( e.display.x, e.display.y ) ).length < r + e.r;
	}
	
	public static inline function isOver( a:Arbiter, contacts:{ left:Bool, right:Bool, bottom:Bool, top:Bool } )
	{
		var r = a.collisionArbiter.normal.angle;
		
		var flat = PhysicManager.i().space.gravity.angle + PI;//1.5 * Math.PI;
		var limit = QUART_PI;
		
		r -= flat;
		while ( r < 0 )
			r += DOUBLE_PI;
		r %= DOUBLE_PI;
		
		if ( r > -QUART_PI && r < QUART_PI )
			contacts.bottom = true;
		else if ( r > QUART_PI && r < QUART_PI + HALF_PI )
			contacts.left = true;
		else if ( r > (QUART_PI + HALF_PI) && r < (PI + QUART_PI) )
			contacts.top = true;
		else if ( r > (PI + QUART_PI) && r < PI + HALF_PI + QUART_PI )
			contacts.right = true;
	}
	
	public function dispose()
	{
		if ( body != null && body.space != null )
			body.space = null;
		
		if ( display != null && display.parent != null )
			display.parent.removeChild( display );
	}
	
}