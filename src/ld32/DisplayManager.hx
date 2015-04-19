package ld32;

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
		//addChild( direction );
		addChild( layer );
		addChild( overlay );
		
		#if debug
			debug = new Sprite();
			addChild( debug );
		#end
	}
	
	public function addLevel( level:LevelUI )
	{
		/*var w = level.wallsUI.width;	
		var h = level.wallsUI.height;	
		
		var tw = Math.round(w / 32);
		var th = Math.round(h / 32);
		var tempBD = new BitmapData( tw, th, false );
		tempBD.perlinNoise( tw * 0.25, th * 0.25, 4, 0, false, true, 7, false );
		var m = 1.3;
		var o = 128;
		tempBD.colorTransform( new Rectangle(0, 0, tw, th), new ColorTransform(m, m, m, 1, o, o, o) );
		var b = new Bitmap( tempBD, PixelSnapping.NEVER, false );
		
		var m = new Matrix();
		m.createBox( 32, 32 );
		
		var bg = new BitmapData( Math.round(w), Math.round(h), false );
		bg.draw( b, m );
		bg.draw( level.graphicUI );*/
		
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
		
		/*var b = new Bitmap( bg, PixelSnapping.AUTO, true );
		b.x = -w * 0.5;
		b.y = -h * 0.5;*/
		
		
	}
	
}