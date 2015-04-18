package ld32;

/**
 * ...
 * @author Namide (Damien Doussaud)
 */
class EntityManager
{
	public static var MAIN:EntityManager;
	public static function i() { return ( MAIN == null ) ? (MAIN = new EntityManager()) : MAIN; }
	
	public var entities:Array<Entity>;
	
	function new() 
	{
		entities = [];
	}
	
	public function add(e:Entity)
	{
		entities.push(e);
		e.body.space = PhysicManager.i().space;
		DisplayManager.i().addChild( e.display );
	}
	
	public function upd( t:Float )
	{
		for ( e in entities )
			e.upd( t );
	}
	
}