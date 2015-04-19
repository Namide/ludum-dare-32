package ld32;
import flash.media.SoundChannel;
import flash.media.SoundTransform;
import flash.net.URLRequest;

/**
 * ...
 * @author Namide (Damien Doussaud)
 */
class Sound
{
	var _mutted:Bool;
	var _music:flash.media.Sound;
	var _chan:SoundChannel;
	
	public function new() 
	{
		_mutted = false;
		start();
	}
	
	function start()
	{
		_music = new flash.media.Sound( new URLRequest("music.mp3") );
		_chan = _music.play( 0, 10000 );
	}
	
	public function playStopAll()
	{
		_mutted = !_mutted;
		if ( _mutted )
		{
			var st = _chan.soundTransform;
			st.volume = 0;
			_chan.soundTransform = st;
		}
		else
		{
			var st = _chan.soundTransform;
			st.volume = 1;
			_chan.soundTransform = st;
		}
	}
}