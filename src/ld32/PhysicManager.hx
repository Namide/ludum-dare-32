package ld32;
import nape.callbacks.CbEvent;
import nape.callbacks.CbType;
import nape.callbacks.InteractionCallback;
import nape.callbacks.InteractionListener;
import nape.callbacks.InteractionType;
import nape.geom.Vec2;
import nape.phys.Body;
import nape.phys.BodyType;
import nape.shape.Circle;
import nape.shape.Polygon;
import nape.space.Space;

/**
 * ...
 * @author Namide (Damien Doussaud)
 */
class PhysicManager
{
	static var MAIN:PhysicManager;
	public static function i() { return (MAIN == null) ? (MAIN = new PhysicManager()) : MAIN; }
	
	public static inline var G_FORCE = 3000.0;
	
	public static var gravityBottom = new Vec2(0, PhysicManager.G_FORCE);
	public static var gravityLeft = new Vec2(-PhysicManager.G_FORCE, 0);
	public static var gravityTop = new Vec2(0, -PhysicManager.G_FORCE);
	public static var gravityRight = new Vec2(PhysicManager.G_FORCE, 0);
	
	public var currentGravity:Vec2;
	public var space:Space;
	
	//var _bil:InteractionListener;
	//var _eil:InteractionListener;
	
	var _w:Int;
	var _h:Int;
	
	function new() 
	{
		space = new Space();
	}
	
	public function changeG( newG:Vec2 )
	{
		space.gravity = newG;
		currentGravity = newG;
		
		var angle = newG.angle - Entity.HALF_PI;
		space.bodies.foreach( function ( b:Body )
		{
			/*if ( b.type == BodyType.DYNAMIC )
			{
				b.rotation = angle;
			}*/
			if ( b.userData.name == "player" || b.userData.name == "box1" )
			{
				motion.Actuate.tween( b, 0.5, { rotation: modRotRad(b.rotation, -angle) } ).ease (motion.easing.Sine.easeInOut);
			}
		} );
		
		//Actuate
		
		//Game.main.rotation = -angle * 180 / Math.PI;
		//motion.Actuate.tween (_playerMesh, 0.5, {z:0} ).ease (motion.easing.Sine.easeIn).onComplete ( function():Void { _playerControl.blockControls = false; _sound.playSound(); } );
		
		motion.Actuate.tween( Game.main, 2, { rotation: modRotDegrees(Game.main.rotation, angle * Entity.RAD_TO_DEGREES ) } ).ease (motion.easing.Sine.easeInOut).delay( 0.25 );
	}
	
	public static function modRotRad( prev:Float, next:Float )
	{
		next = -next;
		while ( next >  prev + Entity.PI  )
			next -= Entity.DOUBLE_PI;
			
		while ( next <  prev - Entity.PI  )
			next += Entity.DOUBLE_PI;
			
		return next;
	}
	
	public static function modRotDegrees( prev:Float, next:Float )
	{
		next = -next;
		while ( next >  prev + 180  )
			next -= 360;
			
		while ( next <  prev - 180  )
			next += 360;
			
		return next;
	}
	
	/*public function onInteractionBegin( interactionCallback:InteractionCallback ) {

		//var a:INapePhysicsObject = interactionCallback.int1.userData.myData;
		//var b:INapePhysicsObject = interactionCallback.int2.userData.myData;

		var a = interactionCallback.int1;
		var b = interactionCallback.int2;
		
		if ( a.userData != null )
			Platformer.isOnGround( a, interactionCallback );
			//a.handleBeginContact(interactionCallback);

		if ( b.userData != null )
			Platformer.isOnGround( b, interactionCallback );
		//if (b.beginContactCallEnabled)
		//b.handleBeginContact(interactionCallback);
	}

	public function onInteractionEnd(interactionCallback:InteractionCallback) {

		var a = interactionCallback.int1;
		var b = interactionCallback.int2;
		
		if ( a.userData != null )
			Platformer.isOnGround( a, interactionCallback );
			//a.handleBeginContact(interactionCallback);

		if ( b.userData != null )
			Platformer.isOnGround( b, interactionCallback );
		
		var a:INapePhysicsObject = interactionCallback.int1.userData.myData;
		var b:INapePhysicsObject = interactionCallback.int2.userData.myData;

		if (!a || !b)
			return;

		if (a.endContactCallEnabled)
		a.handleEndContact(interactionCallback);

		if (b.endContactCallEnabled)
		b.handleEndContact(interactionCallback);
	}*/
	
	public function init( level:Level1 )
	{
		_w = Math.round(level.wallsUI.width);
		_h = Math.round(level.wallsUI.height);
		
		space.gravity = PhysicManager.gravityBottom;//new Vec2(0, 1200); // units are pixels/second/second
		
		EntityManager.i().clearEntities();
		
		initWorld( level );
		initItems( level );
		
		
		/*var ball = new Body(BodyType.DYNAMIC);
		ball.shapes.add(new Circle(64));
		ball.position.setxy(64, 0);
		//ball.angularVel = 10;
		ball.space = SPACE;*/
		
		changeG( gravityBottom );
	}
	
	function initItems( level:Level1 )
	{
		
		var i = level.itemsUI.numChildren;
		while ( --i > -1 )
		{
			var s = level.itemsUI.getChildAt(i);
			s.x -= _w * 0.5;
			s.y -= _h * 0.5;
			
			if ( Std.is( s, Box32UI ) || Std.is( s, Box64UI ) )
				EntityManager.i().add( new Box( s ) );
			else if ( Std.is( s, Spikeball32LUI ) || Std.is( s, Spikeball32RUI ) )
				EntityManager.i().add( new Spikes( s ) );
			else if ( Std.is( s, SpawnUI ) )
				EntityManager.i().playerStart(s.x, s.y);
		}
		
		// BOX 1
		/*var box1 = new Body(BodyType.DYNAMIC);
		box1.userData.name = "box1";
		box1.allowRotation = false;
		box1.shapes.add(new Polygon(Polygon.rect( -32, -32, 64, 64)));
		box1.position.setxy(0, 32);
		var entity = new Entity();
		entity.display = new Box32UI();
		entity.body = box1;
		EntityManager.i().add( entity );*/
        
		
		
		
		// SPIKES
		/*for (i in 0...2)
		{
			var entity = new Spikes( i * 16, -(32 * i), 4 );
			EntityManager.i().add( entity );
        }*/
		
	}
	
	function initWorld( level:Level1 )
	{
		var hw = _w * 0.5;
		var hh = _h * 0.5;
		
		for ( i in 0...level.wallsUI.numChildren )
		{
			var s = level.wallsUI.getChildAt(i);
			
			var floorBody = new Body(BodyType.STATIC);
			
			var x:Float = s.x - hw;
			var y:Float = s.y - hh;
			var w:Float = s.width;
			var h:Float = s.height;
			
			if ( Std.is( s, Tile ) )
				floorBody.shapes.add( new Polygon(Polygon.rect( x, y, w, h)) );
			else if ( Std.is( s, TileTL ) )
				floorBody.shapes.add( new Polygon( [Vec2.get(x,y),Vec2.get(x+w,y),Vec2.get(x,y+h)] ) );
			else if ( Std.is( s, TileTR ) )
				floorBody.shapes.add( new Polygon( [Vec2.get(x,y),Vec2.get(x+w,y),Vec2.get(x+w,y+h)] ) );
			else if ( Std.is( s, TileBL ) )
				floorBody.shapes.add( new Polygon( [Vec2.get(x,y),Vec2.get(x+w,y+h),Vec2.get(x,y+h)] ) );
			else if ( Std.is( s, TileBR ) )
				floorBody.shapes.add( new Polygon( [Vec2.get(x+w,y),Vec2.get(x+w,y+h),Vec2.get(x,y+h)] ) );
			else
				continue;
			
			
			floorBody.space = PhysicManager.i().space;
		}
		
		/*var floorBody = new Body(BodyType.STATIC);
		floorBody.shapes.add( new Polygon(Polygon.rect( 10-hw, hh-10, _w-20, 10)) );
		floorBody.space = SPACE;
		
		floorBody = new Body(BodyType.STATIC);
		floorBody.shapes.add( new Polygon(Polygon.rect(10-hw, -hh, _w-20, 10)) );
		floorBody.space = SPACE;
		
		floorBody = new Body(BodyType.STATIC);
		floorBody.shapes.add( new Polygon(Polygon.rect(0-hw, -hh+10, 10, _h-20)) );
		floorBody.space = SPACE;
		
		floorBody = new Body(BodyType.STATIC);
		floorBody.shapes.add( new Polygon(Polygon.rect(hw-20, -hh+10, 10, _h-20)) );
		floorBody.space = SPACE;
		
		var t = 5*32;
		
		floorBody = new Body(BodyType.STATIC);
		floorBody.shapes.add( new Polygon(Polygon.rect(-0.5*t, -hh, t, t)) );
		floorBody.space = SPACE;*/
		
	}
	
	
	public function upd(t:Float)
	{
		PhysicManager.i().space.step( t );
	}
	
}