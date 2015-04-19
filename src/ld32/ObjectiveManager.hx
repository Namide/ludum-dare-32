package ld32;

/**
 * ...
 * @author Namide (Damien Doussaud)
 */
class ObjectiveManager
{
	static var MAIN:ObjectiveManager;
	public static function i() { return (MAIN == null) ? MAIN = new ObjectiveManager() : MAIN; }
	
	function new() 
	{
		
	}
	
	public function validObjective( level:LevelUI )
	{
		if ( ++_objectiveState == 1 )
			EntityManager.i().player.playable = true;
		
		if ( Std.is( level, Level0 ) )
		{
			if ( _objectiveState == 1 )
			{
				
			}
			
		}
		
		
	}
}