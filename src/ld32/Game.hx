package ld32;
import dl.utils.Timer;
import flash.display.DisplayObject;
import flash.display.Sprite;
import flash.display.StageDisplayState;
import flash.Lib;
import ld32.manager.DisplayManager;
import ld32.manager.EntityManager;
import ld32.manager.ObjectiveManager;
import ld32.manager.PhysicManager;
import ld32.util.Sound;

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
	var _music:Sound;
	
	var _entityManager:EntityManager;
	
	#if debug
		public var debug:Debug;
	#end
	
	public function new( w, h ) 
	{
		super();
		
		_music = new Sound();
		main = this;
		
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
		
		
		PhysicManager.i().start( 0 );
		
		
		// DISPLAY
		addChild( DisplayManager.i() );
		
		
		// REFRESH LISTENER
		_timer = new Timer( Std.int(Lib.current.stage.frameRate) );
		_timer.onDisplayUpdate = upd;
		_timer.restart();
		
		
		// Bug if this listener is in PhysicManager ???
		flash.Lib.current.stage.addEventListener( flash.events.KeyboardEvent.KEY_UP, function(e:flash.events.KeyboardEvent) {
			if ( e.keyCode == 8 )
				PhysicManager.i().restart();
			else if ( e.keyCode == 27 )
				PhysicManager.i().start(0);
			else if ( e.keyCode == 77 )
				_music.playStopAll();
			else if ( e.keyCode == 70 )
			{
				if ( flash.Lib.current.stage.displayState == StageDisplayState.NORMAL )
				{
					try {
						flash.Lib.current.stage.displayState = StageDisplayState.FULL_SCREEN;
					}
					catch (e:Dynamic) { }
				}
			}
			
		} );
	}
	
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