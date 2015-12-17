package tones.examples;
import haxe.Timer;
import tones.data.OscillatorType;
/**
 * ...
 * @author Mike Almond - https://github.com/mikedotalmond
 */
class ReleaseLater {

	public function new() {
		
		var tones = new Tones(); // create 
		
		// change some settings...
		tones.type = OscillatorType.SQUARE;
		tones.volume = .02;
		tones.attack = .5;
		tones.release = 1.5;
		
		// wait .1 seconds, then play a note that won't release until you call doRelease(id)
		var noteId1 = tones.playFrequency(220, 0, false);
		
		// play a second tone slightly after the previous
		tones.volume = .03;
		tones.type = OscillatorType.SAWTOOTH;
		var noteId2 = tones.playFrequency(111, 1, false);
		//
		// wait 2 seconds, then release
		Timer.delay(function() {
			tones.doRelease(noteId1);			
			tones.doRelease(noteId2);			
		}, 2000);
	}
	
}