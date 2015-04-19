package ld32;

import flash.display.Sprite;
import haxe.Timer;
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
	var levelList:Array<Class<LevelUI>>;
	var currentLevel:Int;
	
	static var MAIN:PhysicManager;
	public static function i() { return (MAIN == null) ? (MAIN = new PhysicManager()) : MAIN; }
	
	public static inline var G_FORCE = 3000.0;
	
	public static var gravityBottom = new Vec2(0, PhysicManager.G_FORCE);
	public static var gravityLeft = new Vec2(-PhysicManager.G_FORCE, 0);
	public static var gravityTop = new Vec2(0, -PhysicManager.G_FORCE);
	public static var gravityRight = new Vec2(PhysicManager.G_FORCE, 0);
	
	public var currentGravity:Vec2;
	public var space:Space;
	
	//var _objectiveState:Int;
	
	//var _bil:InteractionListener;
	//var _eil:InteractionListener;
	
	var _enemies:Array<Entity>;
	
	var _w:Int;
	var _h:Int;
	
	//var _controller:dl.input.Keyboard;
	
	function new() 
	{
		currentLevel = -1;
		levelList = [ Level3, Level2, Level0, Level1 ];
		space = new Space();
		
		//_controller = new dl.input.Keyboard(0);
		//_controller.addKeyListener( 8, null, restart );
		
	}
	
	public function restart()
	{
		//trace("restart");
		start(currentLevel);
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
		var w = DisplayManager.i().world;
		motion.Actuate.tween( w, 2, { rotation: modRotDegrees(w.rotation, angle * Entity.RAD_TO_DEGREES ) } ).ease (motion.easing.Sine.easeInOut).delay( 0.25 );
		
		#if debug
			w = DisplayManager.i().debug;
			motion.Actuate.tween( w, 2, { rotation: modRotDegrees(w.rotation, angle * Entity.RAD_TO_DEGREES ) } ).ease (motion.easing.Sine.easeInOut).delay( 0.25 );
		#end
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
	
	public function start( numLevel:Int )
	{
		EntityManager.i().clearEntities();
		ObjectiveManager.i().restart();
	
		
		
		currentLevel = numLevel;
		var level:LevelUI = Type.createInstance( levelList[numLevel], [] );
		
		_w = Math.round(level.wallsUI.width);
		_h = Math.round(level.wallsUI.height);
		
		space.gravity = PhysicManager.gravityBottom;//new Vec2(0, 1200); // units are pixels/second/second
		
		EntityManager.i().clearEntities();
		
		initWorld( level );
		initItems( level );
		initGoal( level );
		
		
		/*var ball = new Body(BodyType.DYNAMIC);
		ball.shapes.add(new Circle(64));
		ball.position.setxy(64, 0);
		//ball.angularVel = 10;
		ball.space = SPACE;*/
		
		changeG( gravityBottom );
		
		DisplayManager.i().addLevel(level);
	}
	
	function dead()
	{
		_enemies = null;
		EntityManager.i().player.dead();
		var t = 3;
		var d = new DeadUI();
		
		DisplayManager.i().layer.addChild( d );
		ObjectiveManager.i().animSprite( d );
		
		ObjectiveManager.i().onComplete = null;
		
		Timer.delay( restart, Math.round(t * 1000) );
	}
	
	function initGoal( level:LevelUI )
	{
		var msg = level.textUI;
		msg.gotoAndStop( 1 );
		msg.scaleX = msg.scaleY = 0.5;
		msg.alpha = 0;
		msg.x = msg.y = 0;
		EntityManager.i().message = msg;
		DisplayManager.i().layer.addChild( msg );
		
		EntityManager.i().player.removeListener();
		EntityManager.i().player.onDead = dead;
		
		//_objectiveState = 0;
		var t = motion.Actuate.tween( msg, 0.5, { scaleX:1, scaleY:1, alpha:1 } ).ease (motion.easing.Sine.easeOut).delay( 0.1 );
		motion.Actuate.tween( msg, 0.5, { scaleX:0.5, scaleY:0.5, alpha:0 }, false )
					.ease(motion.easing.Sine.easeOut).delay( 2 )
					.onComplete( function() { /*if ( msg != null && msg.parent != null )*/ msg.visible = false; ObjectiveManager.i().validObjective(level); } );
		
		
		
		
		
		ObjectiveManager.i().onComplete = levelComplete;
		
		/*if ( Std.is( level, Level1 ) )
		{
			motion.Actuate.tween( msg, 1, { scaleX:0.5, scaleY:0.5, alpha:0 }, false )
					.ease(motion.easing.Sine.easeOut).delay( 3 )
					.onComplete( function() { if ( msg != null && msg.parent != null ) msg.parent.removeChild(msg); } );
		}*/
		
	}
	
	function levelComplete()
	{
		//EntityManager.i().player.dead();
		EntityManager.i().player.isPlayable = false;
		_enemies = null;
		
		var t = 3;
		var d:Sprite;
		
		if ( ++currentLevel < levelList.length )
		{
			d = new WPUI();
			//start( currentLevel );
			Timer.delay( function() { start( currentLevel ); }, Math.round(t * 1000) );
		}
		else
		{
			d = new GOUI();
			Timer.delay( function() { start( 0 ); }, Math.round(t * 1000) );
			
			//ObjectiveManager.i().onComplete = null;
			//trace("game finish!");
		}
		
		ObjectiveManager.i().onComplete = null;
		DisplayManager.i().layer.addChild( d );
		ObjectiveManager.i().animSprite( d );
		
	}
	
	function initItems( level:LevelUI )
	{
		_enemies = []; 
		var i = level.itemsUI.numChildren;
		while ( --i > -1 )
		{
			var s = level.itemsUI.getChildAt(i);
			s.x -= _w * 0.5;
			s.y -= _h * 0.5;
			
			if ( Std.is( s, Box32UI ) || Std.is( s, Box64UI ) )
			{
				var b = new Box( s );
				EntityManager.i().add( b );
				ObjectiveManager.i().toCombine.rocks.push( s );
				ObjectiveManager.i().toCombine.targetVel.push( b.body );
			}
			else if ( Std.is( s, Spikeball32LUI ) || Std.is( s, Spikeball32RUI ) )
			{
				var sp = new Spikes( s );
				_enemies.push( sp );
				EntityManager.i().add( sp );
			}
			else if ( Std.is( s, SpawnUI ) )
				EntityManager.i().playerStart(s.x, s.y);
			else if ( Std.is( s, End64UI ) )
			{
				EntityManager.i().add( new End( s ), true );
				ObjectiveManager.i().toCombine.objective.push(s);
			}
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
	
	function initWorld( level:LevelUI )
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
		
		if ( _enemies != null )
		{
			var p = EntityManager.i().player;
			for ( e in _enemies )
			{
				if ( p.hitTest( e ) )
					dead();
			}
		}
	}
	
}