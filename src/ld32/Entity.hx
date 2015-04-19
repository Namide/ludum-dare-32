package ld32;
import flash.display.DisplayObject;
import nape.callbacks.CbEvent;
import nape.callbacks.CbType;
import nape.callbacks.InteractionCallback;
import nape.callbacks.InteractionListener;
import nape.callbacks.InteractionType;
import nape.dynamics.Arbiter;
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
	
	
	public var display:DisplayObject;
	public var body:Body;
	
	public function new() 
	{
		//new InteractionListener(CbEvent.BEGIN, InteractionType.COLLISION, CbType.ANY_BODY, CbType.ANY_BODY, handleBeginContact);
		
		/*_beginInteractionListener = new InteractionListener(CbEvent.BEGIN, InteractionType.ANY, CbType.ANY_BODY, CbType.ANY_BODY, onInteractionBegin);*/
		/*_endInteractionListener = new InteractionListener(CbEvent.END, InteractionType.ANY, CbType.ANY_BODY, CbType.ANY_BODY, onInteractionEnd);*/
			
	}
	
	public function upd( t:Float )
	{
		if ( body != null && !body.isSleeping )
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
	
	public static inline function isOver( a:Arbiter, contacts:{ left:Bool, right:Bool, bottom:Bool, top:Bool } )
	{
		//trace( PhysicManager.space.gravity.angle + Math.PI );
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
		
		//else if ( r > -(QUART_PI + HALF_PI) && r < -QUART_PI )
		//	contacts.right = true;
		
		//if ( r < limit && r > -limit )
		//	return true;
		
		//return false;
	}
	
	public function dispose()
	{
		if ( body != null && body.space != null )
			body.space = null;
		
		if ( display != null && display.parent != null )
			display.parent.removeChild( display );
	}
	
	/*public static function isOnGround( body:Interactor, ic:InteractionCallback)
	{
		var nd = cast( body.userData.napeDatas, NapeDatas );
		trace(1, nd);
		if ( !nd.onGroundEnabled )
			return;
		
		var collider:Interactor = CollisionGetOther(body, ic);
			
		//trace( body.arbiters.length );
		if (ic.arbiters.length > 0 && ic.arbiters.at(0).collisionArbiter != null ) {
			
			var collisionAngle = ic.arbiters.at(0).collisionArbiter.normal.angle * 180 / Math.PI;
			
			if ((collisionAngle > 45 && collisionAngle < 135) || (collisionAngle > -30 && collisionAngle < 10) || collisionAngle == -90)
			{
				if (collisionAngle > 1 || collisionAngle < -1) {
					//we don't want the Hero to be set up as onGround if it touches a cloud.
					//if (collider is Platform && (collider as Platform).oneWay && collisionAngle == -90)
					//	return;
					
					//_groundContacts.push(collider.body);
					//_onGround = true;
					//updateCombinedGroundAngle();
					
					if ( nd.onGroundEnabled )
						nd.onGroundList.push( collider );
					//return;
				}
			}
		}
		
		//if ( nd.onGroundEnabled )
		//	nd.onGround = false;
		//return;
	}
	
	public static function handleEndContact( body:Interactor, ic:InteractionCallback )
	{
		//isOnGround( body, ic );
		
		var nd = cast( body.userData, NapeDatas );
		//trace(1, nd);
		if ( !nd.onGroundEnabled )
			return;
			
		//var collider:NapePhysicsObject = NapeUtils.CollisionGetOther(this, callback);
		var collider:Interactor = CollisionGetOther(body, ic);
		
		//Remove from ground contacts, if it is one.
		var index = nd.onGroundList.indexOf( collider );
		if (index != -1)
		{
			nd.onGroundList.splice(index, 1);
			
			//if (_groundContacts.length == 0)
			//	_onGround = false;
			//updateCombinedGroundAngle();
		}
	}*/
	
	
	
}