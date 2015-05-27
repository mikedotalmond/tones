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
class Basic {
	
	var tones:Tones;
	
	public function new() {
		
		tones = new Tones(); // create 
		tones.playFrequency(440); // play a 440Hz tone with the default settings.
		
		// change some settings...
		tones.volume = .05;
		tones.attack = .500;
		
		// NoteFrequencyUtil has various util/conversion functions for working with musical notes and frequencies
		var freqUtil = new NoteFrequencyUtil();
		tones.playFrequency(freqUtil.noteNameToFrequency('G3'), 1); // play a G3 tone after 1 second.
		
	}	
}