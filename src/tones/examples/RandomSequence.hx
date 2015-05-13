package tones.examples;

import haxe.Json;
import haxe.Timer;
import js.Browser;
import tones.Tones;

import tones.OscillatorType;
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
		
		tones.toneBegin.connect(onToneBegin);
		tones.toneEnd.connect(onToneEnd);
		
		playRandom(); // start it off...
	}
	
	function playRandom() {
		
		tones.volume = .001 + Math.random() * .04;
		tones.attack = Math.random() * Math.random() * 250;
		tones.release = 10 + Math.random() * Math.random() * 500;
		
		var freq = 50 + Math.random() * 600; // 50Hz - 650Hz
		var delay = Math.random(); // delay from 0-1 seconds before playing
		
		tones.playFrequency(freq, delay);
	}
	
	function onToneBegin(id:Int, polyphony:Int) {
		// a tone has just started to play,
		// if the current polyphony (number of active tones) is less than 3 - play another
		if (polyphony < 3) playRandom(); 
	}
	
	function onToneEnd(id:Int, polyphony:Int) {
		if (polyphony < 3) playRandom(); // play again as soon as a tone has ended - this will keep it playing forever!
	}
}