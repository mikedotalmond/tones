package;

import js.Lib;

/**
 * ...
 * @author Mike Almond - https://github.com/mikedotalmond
 */

class Main {
	
	static function main() {
		
		var t = new Tones();
		t.volume = .1;
		
		t.playFrequency(440);
		t.playNote('a', 3);
		
		t.play({
			freq	:280,
			volume	:.1, 
			attack	:5, 
			release	:25, 
			type	:Tones.OscillatorType.SAWTOOTH,
		});
		
		t.play({ 
			freq	:Tones.getNoteFreq('g#', 3),
			volume	:.05, 
			attack	:1000, 
			release	:500, 
			type	:Tones.OscillatorType.SQUARE,
		});
		
	}
	
}