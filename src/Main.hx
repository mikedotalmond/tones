package;

import js.Browser;
import tones.examples.*;

/**
 * ...
 * @author Mike Almond - https://github.com/mikedotalmond
 */
class Main {
	
	static function main() {
		
		var h = Browser.document.location.search;
		switch(h) {
			case "?basic":
				/** The simplest usage **/
				var basic = new Basic();
				
			case "?releaseLater":
				/** Play and hold a tone, then release it later **/
				var releaseLater = new ReleaseLater();
		
			case "?sharedContext":
				/** Sharing, or using a shared, AudioContext **/
				var sharedContext = new SharedContext();
		
			case "?customWaves":
				/** load and use wavetable data **/
				var customWaves = new CustomWaves();
		
			case "?sequence":
				/** simple sequencing examples **/
				var sequence = new Sequence();
				
			case "?polysynth":
				/** 
				 * Something a bit more complete that combines stuff seen in the earlier examples 
				 * - 2x Tones instances with a shared context and common output gain
				 * - 2nd Oscillator is slightly detuned and has a phase offset (changes randomly on each note)
				 * - wavetables (periodicWave)
				 * - keyboard controls to play notes
				 * - dat.GUI controls
				 * **/
				var polysynth = new KeyboardControlled();
			
			default: 
				Browser.document.location.search = '?basic';
		}
	}
}