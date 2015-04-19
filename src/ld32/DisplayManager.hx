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
	
	public function new() 
	{
		super();
		
	}
	
	public function addLevel( level:LevelUI )
	{
		var graphic = level.graphicUI;
		graphic.x = -level.wallsUI.width * 0.5;
		graphic.y = -level.wallsUI.height * 0.5;
		graphic.cacheAsBitmap = true;
		addChild( graphic );
	}
	
}