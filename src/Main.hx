package;

import flash.display.StageAlign;
import flash.display.StageScaleMode;
import flash.Lib;
import ld32.Game;

/**
 * ...
 * @author Namide (Damien Doussaud)
 */

class Main 
{
	
	static var _g:Game;
	
	static function main() 
	{
		var stage = Lib.current.stage;
		//stage.scaleMode = StageScaleMode.NO_SCALE;
		//stage.align = StageAlign.TOP_LEFT;
		
		_g = new Game();
		stage.addChild( _g );
	}
	
}