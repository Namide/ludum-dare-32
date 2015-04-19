package ld32;

import flash.display.Sprite;

/**
 * ...
 * @author Namide (Damien Doussaud)
 */
class DisplayManager extends Sprite
{
	public static var MAIN:DisplayManager;
	public static function i() { return ( MAIN == null ) ? (MAIN = new DisplayManager()) : MAIN; }
	
	public var world:Sprite;
	public var layer:Sprite;
	
	#if debug
		public var debug:Sprite;
	#end
	
	
	var w:Int;
	var h:Int;
	
	public function new() 
	{
		super();
	}
	
	public function init( w:Int, h:Int )
	{
		this.w = w;
		this.h = h;
		world = new Sprite();
		layer = new Sprite();
		addChild( world );
		addChild( layer );
		
		#if debug
			debug = new Sprite();
			addChild( debug );
		#end
	}
	
	public function addLevel( level:LevelUI )
	{
		var graphic = level.graphicUI;
		graphic.x = -level.wallsUI.width * 0.5;
		graphic.y = -level.wallsUI.height * 0.5;
		graphic.cacheAsBitmap = true;
		world.addChildAt( graphic, 0 );
	}
	
}