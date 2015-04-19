package ld32;

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
	
	function new() 
	{
		entities = [];
	}
	
	public function playerStart( x:Float, y:Float )
	{
		player = new Player();
		
		//remove( player );
		player.body.position.setxy( x, y );
		DisplayManager.i().addChild( player.display );
		player.body.space = PhysicManager.i().space;
		add( player );
	}
	
	public function add(e:Entity)
	{
		entities.push(e);
		e.body.space = PhysicManager.i().space;
		DisplayManager.i().addChild( e.display );
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
		for ( e in entities )
			e.dispose();
		
		entities = [];
	}
	
	
}