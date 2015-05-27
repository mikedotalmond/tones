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
		
		playRandom(tones.now); // start it off...
	}
	
	function playRandom(time) {
		
		tones.volume = .001 + Math.random() * .04;
		tones.attack = .010 + Math.random() * Math.random() * .500;
		tones.release = .020 + Math.random() * Math.random() * .500;
		
		var freq = 50 + Math.random() * 600; // 50Hz - 650Hz
		var delay = time+Math.random(); // delay from 0-1 seconds before playing
		
		tones.playFrequency(freq, delay-tones.now);
	}
	
	function onToneBegin(id:Int, time:Float) {
		// a tone has just started to play,
		// if the current polyphony (number of active tones) is less than 3 - play another
		if (tones.polyphony < 3) playRandom(time); 
	}
	
	function onToneEnd(id:Int) {
		if (tones.polyphony < 3) playRandom(0); // play again as soon as a tone has ended - this will keep it playing forever!
	}
}