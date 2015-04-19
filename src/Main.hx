package;

import flash.display.StageAlign;
import flash.display.StageScaleMode;
import flash.events.Event;
import flash.Lib;
import ld32.Game;
import ld32.Sound;

/**
 * ...
 * @author Namide (Damien Doussaud)
 */

class Main 
{
	static public var W:Int = 900;
	static public var H:Int = 900;
	
	static var _g:Game;
	
	static function main() 
	{
		var stage = Lib.current.stage;
		stage.addEventListener( Event.RESIZE, onResize );
		stage.scaleMode = StageScaleMode.NO_SCALE;
		stage.align = StageAlign.TOP_LEFT;
		
		_g = new Game( W, H );
		stage.addChild( _g );
		onResize();
		
		
	}
	
	static function onResize(e:Dynamic = null)
	{
		var stage = Lib.current.stage;
		
		var o = { w:W, h:H, p:1.0 };
		var c = { w:stage.stageWidth, h:stage.stageHeight, p:0.0 };
		c.p = c.w / c.h;
		
		var s = 1.0;
		if ( c.p < o.p )
			s = c.w / o.w;
		else
			s = c.h / o.h;
		
		_g.scaleX = _g.scaleY = s;
		_g.x = Math.fround( c.w * 0.5 );
		_g.y = Math.fround( c.h * 0.5 );
	}
}