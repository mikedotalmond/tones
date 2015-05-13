package tones.examples;
import haxe.Timer;

/**
 * ...
 * @author Mike Almond - https://github.com/mikedotalmond
 */
class ReleaseLater {

	public function new() {
		
		var tones = new Tones(); // create 
		
		// change some settings...
		tones.type = OscillatorType.SAWTOOTH;
		tones.volume = .2;
		tones.attack = 200;
		tones.release = 2500;
		
		// wait .1 seconds, then play a note that won't release until you call doRelease(id)
		var noteId = tones.playFrequency(540, .1, false); // play a 440Hz tone with the default settings.
		
		// wait 2.5 seconds, then release
		Timer.delay(function() {
			tones.doRelease(noteId);			
		}, 2500);
	}
	
}