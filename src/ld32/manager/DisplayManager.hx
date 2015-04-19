package ld32.manager;

import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.display.PixelSnapping;
import flash.display.Sprite;
import flash.geom.ColorTransform;
import flash.geom.Matrix;
import flash.geom.Rectangle;

/**
 * ...
 * @author Namide (Damien Doussaud)
 */
class DisplayManager extends Sprite
{
	public static var MAIN:DisplayManager;
	public static function i() { return ( MAIN == null ) ? (MAIN = new DisplayManager()) : MAIN; }
	
	public var world0:Sprite;
	public var world1:Sprite;
	public var layer:Sprite;
	public var overlay:Sprite;
	public var direction:Sprite;
	
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
		world0 = new Sprite();
		world1 = new Sprite();
		layer = new Sprite();
		overlay = new OverlayUI();
		direction = new DirUI();
		addChild( world0 );
		addChild( world1 );
		addChild( layer );
		addChild( overlay );
		
		#if debug
			debug = new Sprite();
			addChild( debug );
		#end
	}
	
	public function addLevel( level:LevelUI )
	{
		
		var bg = level.bgUI;
		bg.x = -768 * 0.5;
		bg.y = -768 * 0.5;
		bg.cacheAsBitmap = true;
		
		world0.addChildAt( direction, 0 );
		world0.addChildAt( bg, 0 );
		
		
		var layer = level.layerUI;
		layer.x = -768 * 0.5;
		layer.y = -768 * 0.5;
		layer.cacheAsBitmap = true;
		
		world1.addChildAt( layer, 0 );
		
	}
	
}