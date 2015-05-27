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
		tones.volume = .05;
		tones.attack = .200;
		tones.release = 2.5;
		
		// wait .1 seconds, then play a note that won't release until you call doRelease(id)
		var noteId1 = tones.playFrequency(220, .1, false);
		
		// play a second tone ery slightly after the precious
		tones.volume = .03;
		tones.type = OscillatorType.SAWTOOTH;
		var noteId2 = tones.playFrequency(111, .1001, false);
		
		// wait 2.25 seconds, then release
		Timer.delay(function() {
			tones.doRelease(noteId1);			
			tones.doRelease(noteId2);			
		}, 2250);
	}
	
}