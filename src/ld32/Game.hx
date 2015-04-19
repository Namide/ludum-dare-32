package ld32;
import dl.utils.Timer;
import flash.display.DisplayObject;
import flash.display.Sprite;
import flash.Lib;

#if debug
	import nape.util.BitmapDebug;
	import nape.util.Debug;
	import nape.util.ShapeDebug;
#end

/**
 * ...
 * @author Namide (Damien Doussaud)
 */
class Game extends Sprite
{
	public static var main:Game;

	var _timer:Timer;
	
	var _entityManager:EntityManager;
	//var _physicMg:PhysicManager;
	
	#if debug
		public var debug:Debug;
	#end
	
	//var _player:Player;
	
	
	public function new() 
	{
		super();
		
		main = this;
		
		// SIZE
		var w = 800;
		var h = 800;
		this.x = w / 2;
		this.y = h / 2;
		
		
		DisplayManager.i().init( w, h );
		
		
		// DEBUG DISPLAY
		#if debug
			debug = new ShapeDebug(w, h, 0xCCCCCC);
			debug.transform.tx = w / 2;
			debug.transform.ty = h / 2;
			debug.display.x = -w / 2;
			debug.display.y = -h / 2;
			DisplayManager.i().debug.addChild(debug.display);
		#end
		
		
		//var level = new Level0();
		PhysicManager.i().start( 0 );
		
		
		// DISPLAY
		addChild( DisplayManager.i() );
		//DisplayManager.i().x = -w / 2;
		//DisplayManager.i().y = -h / 2;
		
		// REFRESH LISTENER
		_timer = new Timer( Std.int(Lib.current.stage.frameRate) );
		_timer.onDisplayUpdate = upd;
		_timer.restart();
		
		
		// ROTATION
		//haxe.Timer.delay( changeG, 6000 );
		
		
		// Bug if this listener is in PhysicManager ???
		flash.Lib.current.stage.addEventListener( flash.events.KeyboardEvent.KEY_UP, function(e:flash.events.KeyboardEvent) { if ( e.keyCode == 8 ) PhysicManager.i().restart(); } );
	}
	
	/*public function changeG()
	{
		var r = Math.random();
		if ( r < 0.25 )
			PhysicManager.changeG( PhysicManager.gravityTop );
		else if ( r < 0.5 )
			PhysicManager.changeG( PhysicManager.gravityBottom );
		else if ( r < 0.75 )
			PhysicManager.changeG( PhysicManager.gravityLeft );
		else
			PhysicManager.changeG( PhysicManager.gravityRight );
		
		haxe.Timer.delay( changeG, 6000 );
		
	}*/
	
	function upd( t:Float )
	{
		if ( t <= 0 )
			return;
		
		PhysicManager.i().upd(t);
		EntityManager.i().upd(t);
		ObjectiveManager.i().upd(t);
		
		#if debug
			debug.clear();
			debug.draw(PhysicManager.i().space);
			debug.flush();
		#end
	}
}