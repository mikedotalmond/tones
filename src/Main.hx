package;

import tones.examples.*;

/**
 * ...
 * @author Mike Almond - https://github.com/mikedotalmond
 */
class Main {
	
	static function main() {
		
		/** The simplest usage **/
		//var basic = new Basic();
		
		/** Play and hold a tone, then release it later **/
		//var releaseLater = new ReleaseLater();
		
		/** Sharing, or using a shared, AudioContext **/
		//var sharedContext = new SharedContext();
		
		/** **/
		//var customWaves	= new CustomWaves();
		
		/** 
		 * Something a bit more complete that combines stuff seen in the earlier examples 
		 * - 2x Tones instances with a shared context and common output gain
		 * - 2nd Oscillator is slightly detuned and has a phase offset (changes randomly on each note)
		 * - wavetables (periodicWave)
		 * - keyboard controls to play notes
		 * - dat.GUI controls
		 * **/
		var polysynth = new KeyboardControlled();
	}
}