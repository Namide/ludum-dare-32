package  {
	import flash.text.TextField;
	import flash.display.MovieClip;
	
	public class GameOverUI extends MovieClip {

		public function GameOverUI() {
			super();
		}

		public function changeTime( t:Number )
		{
			var tx:TextField = TextField( getChildByName("timeT") );
			tx.appendText( String(t) + " sec" );
		}

	}
	
}
