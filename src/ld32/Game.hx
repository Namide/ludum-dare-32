package ld32;
import dl.utils.Timer;
import flash.display.DisplayObject;
import flash.display.Sprite;
import flash.Lib;
import nape.util.BitmapDebug;
import nape.util.Debug;
import nape.util.ShapeDebug;

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
	var _debug:Debug;
	
	//var _player:Player;
	
	
	public function new() 
	{
		super();
		
		main = this;
		
		var level = new Level1();
		PhysicManager.i().init( level );
		DisplayManager.i().addLevel(level);
		
		// SIZE
		var w = 800;
		var h = 800;
		this.x = w / 2;
		this.y = h / 2;
		
		
		// DISPLAY
		addChild( DisplayManager.i() );
		//DisplayManager.i().x = -w / 2;
		//DisplayManager.i().y = -h / 2;
		
		// DEBUG DISPLAY
		_debug = new ShapeDebug(w, h, 0xCCCCCC);
		_debug.transform.tx = w / 2;
		_debug.transform.ty = h / 2;
		_debug.display.x = -w / 2;
		_debug.display.y = -h / 2;
        addChild(_debug.display);
		
		
		// REFRESH LISTENER
		_timer = new Timer( Std.int(Lib.current.stage.frameRate) );
		_timer.onDisplayUpdate = upd;
		_timer.restart();
		
		
		// ROTATION
		//haxe.Timer.delay( changeG, 6000 );
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
		PhysicManager.i().upd(t);
		EntityManager.i().upd(t);
		
		_debug.clear();
		_debug.draw(PhysicManager.i().space);
		_debug.flush();
	}
	
}