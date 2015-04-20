package ld32.manager;

import flash.display.Sprite;
import flash.events.MouseEvent;
import flash.Lib;
import haxe.Timer;
import ld32.entities.Box;
import ld32.entities.End;
import ld32.entities.Entity;
import ld32.entities.Spikes;
import ld32.manager.DisplayManager;
import ld32.manager.EntityManager;
import ld32.manager.ObjectiveManager;
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
	
	var _enemies:Array<Spikes>;
	
	var _w:Int;
	var _h:Int;
	
	var _startTime:Float;
	
	function new() 
	{
		currentLevel = -1;
		levelList = [ Level0, Level1, Level2, Level3, Level4, Level5 ];
		space = new Space();
	}
	
	public function restart()
	{
		start(currentLevel);
	}
	
	public function changeG( newG:Vec2, time:Float = 2 )
	{
		space.gravity = newG;
		currentGravity = newG;
		
		var angle = newG.angle - Entity.HALF_PI;
		space.bodies.foreach( function ( b:Body )
		{
			if ( b.userData.name == "player" || b.userData.name == "box1" )
			{
				motion.Actuate.tween( b, 0.5, { rotation: modRotRad(b.rotation, -angle) } ).ease (motion.easing.Sine.easeInOut);
			}
		} );
		
		var w = DisplayManager.i().world0;
		motion.Actuate.tween( w, time, { rotation: modRotDegrees(w.rotation, angle * Entity.RAD_TO_DEGREES ) } ).ease (motion.easing.Sine.easeInOut).delay( time / 8 );
		w = DisplayManager.i().world1;
		motion.Actuate.tween( w, time, { rotation: modRotDegrees(w.rotation, angle * Entity.RAD_TO_DEGREES ) } ).ease (motion.easing.Sine.easeInOut).delay( time / 8 );
		
		EntityManager.i().player.refreshArrow(0);
		
		#if debug
			w = DisplayManager.i().debug;
			motion.Actuate.tween( w, time, { rotation: modRotDegrees(w.rotation, angle * Entity.RAD_TO_DEGREES ) } ).ease (motion.easing.Sine.easeInOut).delay( time / 8 );
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
		if ( numLevel >= levelList.length )
			numLevel = 0;
		
		EntityManager.i().clearEntities();
		ObjectiveManager.i().restart();
	
		if ( numLevel < 1 )
			_startTime = haxe.Timer.stamp();
		
		currentLevel = numLevel;
		var level:LevelUI = Type.createInstance( levelList[numLevel], [] );
		
		_w = Math.round(level.wallsUI.width);
		_h = Math.round(level.wallsUI.height);
		
		space.gravity = PhysicManager.gravityBottom;
		
		EntityManager.i().clearEntities();
		
		initWorld( level );
		initItems( level );
		initGoal( level );
		
		
		changeG( gravityBottom, 0 );
		
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
		
		var t = motion.Actuate.tween( msg, 0.5, { scaleX:1, scaleY:1, alpha:1 } ).ease (motion.easing.Sine.easeOut).delay( 0.1 );
		motion.Actuate.tween( msg, 0.5, { scaleX:0.5, scaleY:0.5, alpha:0 }, false )
					.ease(motion.easing.Sine.easeOut).delay( 2 )
					.onComplete( function() { msg.visible = false; ObjectiveManager.i().validObjective(level); } );
		
		
		ObjectiveManager.i().onComplete = levelComplete;
	}
	
	function levelComplete()
	{
		EntityManager.i().player.isPlayable = false;
		_enemies = null;
		
		var t = 3;
		var d:Sprite;
		
		if ( ++currentLevel < levelList.length )
		{
			d = new WPUI();
			Timer.delay( function() { start( currentLevel ); }, Math.round(t * 1000) );
		}
		else
		{
			var go = new GOUI();
			d = go;
			var dt = haxe.Timer.stamp() - _startTime;
			go.timeT.text += Std.string(Math.round( dt * 100 ) / 100) + " sec";
			
			currentLevel = 0;
			Lib.current.stage.addEventListener( MouseEvent.CLICK, clickRestart );
		}
		
		ObjectiveManager.i().onComplete = null;
		DisplayManager.i().layer.addChild( d );
		ObjectiveManager.i().animSprite( d );
		
	}
	
	function clickRestart(e:Dynamic)
	{
		Lib.current.stage.removeEventListener( MouseEvent.CLICK, clickRestart );
		start( 0 );
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
			else if ( 	Std.is( s, Spikeball32UI ) ||
						Std.is( s, Spikeball64UI ) ||
						Std.is( s, Spikeball128UI ) ||
						Std.is( s, Spikeball32SpeedUI ) )
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
		
	}
	
	public function upd(t:Float)
	{
		if ( !EntityManager.i().player.isPlayable )
			return;
		
		PhysicManager.i().space.step( t );
		
		if ( 	EntityManager.i().player.display.x < -Main.W * 0.5 ||
				EntityManager.i().player.display.x > Main.W * 0.5 ||
				EntityManager.i().player.display.y < -Main.H * 0.5 ||
				EntityManager.i().player.display.y > Main.H * 0.5   )
		{
			restart();
		}
		
		if ( _enemies != null )
		{
			var p = EntityManager.i().player;
			for ( e in _enemies )
			{
				if ( 	e.body.angularVel * e.angularVel < 0 ||
						e.body.velocity.length == 0 )
				{
					e.angularVel *= -1;
				}
				
				if ( p.hitTest( e ) )
					dead();
			}
		}
	}
	
}