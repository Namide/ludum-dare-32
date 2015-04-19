package  {
	import flash.display.MovieClip;
	
	public class LevelUI extends MovieClip {

		public var textUI:MovieClip;
		public var wallsUI:MovieClip;
		public var itemsUI:MovieClip;
		public var graphicUI:MovieClip;

		public function LevelUI() {
			super();
			
			textUI = MovieClip(getChildByName("textUI"));
			wallsUI = MovieClip(getChildByName("wallsUI"));
			itemsUI = MovieClip(getChildByName("itemsUI"));
			graphicUI = MovieClip(getChildByName("graphicUI"));
		}

	}
	
}
