package ld32;
import flash.display.DisplayObject;
import flash.display.Sprite;
import nape.geom.Vec2;

typedef Combination = {
	var rocks: Array<DisplayObject>;
	var objective: Array<DisplayObject>;
	var targetVel: Array<nape.phys.Body>;
}

/**
 * ...
 * @author Namide (Damien Doussaud)
 */
class ObjectiveManager
{
	static var MAIN:ObjectiveManager;
	public static function i() { return (MAIN == null) ? MAIN = new ObjectiveManager() : MAIN; }
	
	public var state:Int;
	public var toCombine:Combination;
	public var onComplete:Void->Void;
	
	function new() 
	{
		
	}
	
	public function restart()
	{
		state = 0;
		toCombine = { rocks:[], objective:[], targetVel:[] };
		onComplete = null;
	}
	
	public function animText( frame:Int, time:Float = 0 )
	{
		var msg = EntityManager.i().message;
		//msg.visible = true;
		//msg.scaleX = msg.scaleY = 0.5;
		//msg.alpha = 0;
		msg.gotoAndStop( frame );
		
		/*var t = motion.Actuate.tween( msg, 0.5, { scaleX:1, scaleY:1, alpha:1 } ).ease (motion.easing.Sine.easeOut);
		if ( time > 0 )
		{
			var t = motion.Actuate.tween( msg, 0.5, { scaleX:0.5, scaleY:0.5, alpha:0 }, false )
					.ease(motion.easing.Sine.easeOut).delay( time )
					.onComplete( function() { msg.visible = false; } );
		}*/
		animSprite( msg, time );
		
		//.onComplete( function() { if ( msg != null && msg.parent != null ) msg.parent.removeChild(msg); ObjectiveManager.i().validObjective(level); } );
	}
	
	public function animSprite( s:Sprite, time:Float = 0 )
	{
		EntityManager.i().message.visible = false;
		
		s.visible = true;
		s.scaleX = s.scaleY = 0.5;
		s.alpha = 0;
		var t = motion.Actuate.tween( s, 0.5, { scaleX:1, scaleY:1, alpha:1 } ).ease (motion.easing.Sine.easeOut);
		if ( time > 0 )
		{
			var t = motion.Actuate.tween( s, 0.5, { scaleX:0.5, scaleY:0.5, alpha:0 }, false )
					.ease(motion.easing.Sine.easeOut).delay( time - 1 )
					.onComplete( function() { s.visible = false; } );
		}
	}
	
	public function validObjective( level:LevelUI )
	{
		var player = EntityManager.i().player;
		
		if ( ++state == 1 )
			player.isPlayable = true;
		
		if ( Std.is( level, Level0 ) )
		{
			if ( state == 1 )
			{
				player.onMove = function() { validObjective(level); };
				animText( 2 );
			}
			else if ( state == 2 )
			{
				player.onMove = null;
				player.onJump = function() { validObjective(level); };
				animText( 3 );
			}
			else if ( state == 3 )
			{
				player.onJump = null;
				player.onChangeG = function() { validObjective(level); };
				animText( 4 );
			}
			else if ( state == 4 )
			{
				player.onChangeG = null;
				player.onAppliG = function() { validObjective(level); };
				animText( 5 );
			}
			else if ( state == 5 )
			{
				player.onAppliG = null;
				animText( 6 );
			}
		}
	}
	
	public function upd(t:Float)
	{
		var maxD = 8.0; // 4 pixels
		//var maxV = 1.0; // velocity
		
		for ( v in toCombine.targetVel )
		{
			if ( v.velocity.length > 0 )
				return;
		}
		
		for ( r in toCombine.rocks )
		{
			var dMin = maxD + 1;
			for ( o in toCombine.objective )
				if ( dist( r, o ) < dMin )
					dMin = 0;
			
			if ( dMin > maxD )
				return;
		}
		
		//if ( dist( c.target, c.objective ) > maxD )
		//		return;
		
		
		if ( onComplete != null )
			onComplete();
	}
	
	private inline static function dist( a:DisplayObject, b:DisplayObject )
	{
		return Vec2.get( a.x, a.y ).sub( Vec2.get( b.x, b.y ) ).length;
	}
	
}