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
class Basic {
	
	var tones:Tones;
	
	public function new() {
		
		var freqUtil = new NoteFrequencyUtil();
		
		tones = new Tones();
		
		tones.playFrequency(440); // play a 440Hz tone with the default settings.
		
		
		tones.volume = .05;
		tones.attack = 500;
		
		tones.playFrequency(freqUtil.noteNameToFrequency('C3'));
		
		tones.play({
			freq	:280,
			volume	:.1, 
			attack	:250, 
			release	:250, 
			type	:OscillatorType.SAWTOOTH,
		});
	}	
}