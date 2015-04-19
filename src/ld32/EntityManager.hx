package ld32;
import flash.display.MovieClip;

/**
 * ...
 * @author Namide (Damien Doussaud)
 */
class EntityManager
{
	public static var MAIN:EntityManager;
	public static function i() { return ( MAIN == null ) ? (MAIN = new EntityManager()) : MAIN; }
	
	public var player:Player;
	public var entities:Array<Entity>;
	public var message:MovieClip;
	
	function new() 
	{
		entities = [];
	}
	
	public function playerStart( x:Float, y:Float )
	{
		player = new Player();
		
		//remove( player );
		player.body.position.setxy( x, y );
		DisplayManager.i().world.addChild( player.display );
		player.body.space = PhysicManager.i().space;
		add( player );
	}
	
	public function add(e:Entity, over:Bool = false)
	{
		entities.push(e);
		
		if ( e.body != null )
			e.body.space = PhysicManager.i().space;
		
		DisplayManager.i().world.addChildAt( e.display, (over)?DisplayManager.i().world.numChildren:0 );
	}
	
	public function remove(e:Entity)
	{
		entities.remove(e);
		e.dispose();
	}
	
	public function upd( t:Float )
	{
		player.upd(t);
		for ( e in entities )
			e.upd( t );
	}
	
	public function clearEntities()
	{
		message = null;
		
		for ( e in entities )
			e.dispose();
		
		var dm = DisplayManager.i();
			
		while ( dm.world.numChildren > 0 )
			dm.world.removeChildAt( 0 );
		
		while ( dm.layer.numChildren > 0 )
			dm.layer.removeChildAt( 0 );
		
		PhysicManager.i().space.clear();
	
		entities = [];
	}
	
	
}