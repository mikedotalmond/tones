package;

import js.Browser;
import js.html.KeyboardEvent;

import utils.KeyboardInput;
import utils.KeyboardNotes;

/**
 * ...
 * @author Mike Almond - https://github.com/mikedotalmond
 */

class Main {
	
	static function main() var m = new Main();
	
	var tones			:Tones;
	var keyboardNotes	:KeyboardNotes;
	var keyboardInput	:KeyboardInput;
	var activeKeys		:Array<Bool>;
	
	// For active notes - map note-index (0-128) to the Tones Note ID
	var noteIndexToId	:Map<Int,Int>;
	
	public function new() {
		
		tones 			= new Tones();
		
		keyboardNotes 	= new KeyboardNotes(2);
		keyboardInput 	= new KeyboardInput(keyboardNotes);
		noteIndexToId	= new Map<Int,Int>();
		
		activeKeys 		= new Array<Bool>();
		for (i in 0...256) activeKeys[i] = false;

		tones.type 		= Tones.OscillatorType.SAWTOOTH;
		//todo: stackoverflow.com/questions/20156888/what-are-the-parameters-for-createperiodicwave-in-google-chrome
		// http://www.sitepoint.com/using-fourier-transforms-web-audio-api/
		// https://chromium.googlecode.com/svn/trunk/samples/audio/wave-tables/
		
		// keyboard control...
		Browser.window.addEventListener('keydown', onKeyDown);https:
		Browser.window.addEventListener('keyup', onKeyUp);
		
		keyboardInput.noteOn.connect(handleNoteOn);
		keyboardInput.noteOff.connect(handleNoteOff); 
		
		// some non-keyboard playback tests		
		/*
		tones.playFrequency(380);
		tones.playFrequency(keyboardNotes.noteFreq.noteIndexToFrequency(noteFreq.noteNameToIndex('A3')));
		
		tones.play({
			freq	:280,
			volume	:.1, 
			attack	:250, 
			release	:250, 
			type	:Tones.OscillatorType.SAWTOOTH,
		});
		
		tones.play({ 
			freq	:440,
			volume	:.05, 
			attack	:1000, 
			release	:250, 
			type	:Tones.OscillatorType.SQUARE,
		});
		//*/
	}
	
	function onKeyDown(e:KeyboardEvent) {
		if (!keyIsDown(e.keyCode)) {
			activeKeys[e.keyCode] = true;
			keyboardInput.onQwertyKeyDown(e.keyCode);
		}
	}
	
	function onKeyUp(e:KeyboardEvent) {
		if (keyIsDown(e.keyCode)) {
			activeKeys[e.keyCode] = false;
			keyboardInput.onQwertyKeyUp(e.keyCode);
		}
	}
	
	function handleNoteOn(index:Int, volume:Float) {
		var f = keyboardNotes.noteFreq.noteIndexToFrequency(index);
		tones.volume  = volume;
		tones.attack  = 250;
		tones.release = 1000;
		noteIndexToId.set(index, tones.playFrequency(f, false));
	}
	
	function handleNoteOff(index:Int) {
		tones.releaseNote(noteIndexToId.get(index));
		noteIndexToId.remove(index);
	}
	
	inline public function keyIsDown(code:Int):Bool return activeKeys[code];

}