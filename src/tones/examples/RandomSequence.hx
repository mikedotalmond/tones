package tones.examples;

import haxe.Json;
import haxe.Timer;
import js.Browser;
import tones.Tones;

import tones.data.OscillatorType;
import tones.utils.NoteFrequencyUtil;

/**
 * ...
 * @author Mike Almond - https://github.com/mikedotalmond
 */
class RandomSequence {
	
	var tones:Tones;
	
	public function new() {
		
		tones = new Tones();
		tones.type = OscillatorType.SQUARE;
		
		tones.itemBegin.connect(onToneBegin);
		tones.itemEnd.connect(onToneEnd);
		
		playRandom(); // start it off...
	}
	
	function playRandom() {
		
		tones.volume = .025 + Math.random() * .04;
		tones.attack = .01 + Math.random() * Math.random() * .100;
		tones.release = .10 + Math.random() * Math.random() * .200;
		
		var freq = 50 + Math.random() * 600; // 50Hz - 650Hz
		
		tones.playFrequency(freq, Math.random());
	}
	
	function onToneBegin(id:Int, time:Float) {
		// a tone has just started to play,
		// if the current polyphony (number of active tones) is less than 3 - play another
		if (tones.polyphony < 4) playRandom(); 
	}
	
	function onToneEnd(id:Int) {
		if (tones.polyphony < 2) playRandom(); // play again as soon as a tone has ended - this will keep it playing forever!
	}
}