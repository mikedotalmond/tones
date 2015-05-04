package;

import haxe.Json;
import haxe.Timer;
import js.Browser;
import js.html.Float32Array;
import js.html.KeyboardEvent;
import utils.Wavetables;

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
		
		var w = new Wavetables();
		
		//var Waves = Wavetables.Waves;
		//trace(Wavetables.FileNames);
		
		tones = new Tones();
		tones.playFrequency(440); // play a 440Hz tone with the default settings.
		
		setupKeyboardControls();	
		
		//var wave = tones.context.createPeriodicWave(new Float32Array(Waves[3].real), new Float32Array(Waves[3].imag));
		//tones.customWave = wave;
		
		// Tones.createContext() can also be used to create a new AudioContext
		
		// You can also have multiple instances with a common AudioContext,
		// and if you want,  set a custom output node rather than routing straight to the context.destination
		
		var context = tones.context; // get the AudioContext to share...
		var masterVolume = context.createGain(); // create a gain node to act as master volume
		masterVolume.gain.value = .5;
		masterVolume.connect(context.destination); // connect the volume control to the context's destintion
		
		// Create another tones instance and pass it an existing context and alternate destination node
		var tones2 = new Tones(context, masterVolume);
		
		tones2.volume = .1;
		tones2.type = Tones.OscillatorType.TRIANGLE;
		tones2.playFrequency(220);
		
		// some non-keyboard playback tests		
		///*
		tones.playFrequency(380);
		
		tones.volume = .05;
		tones.attack = 500;
		
		tones.playFrequency(keyboardNotes.noteFreq.noteIndexToFrequency(keyboardNotes.noteFreq.noteNameToIndex('A3')));
		
		tones.play({
			freq	:280,
			volume	:.1, 
			attack	:250, 
			release	:250, 
			type	:Tones.OscillatorType.SAWTOOTH,
		});
		
		// A sustained note - pass autoRelease false, then call releaseNote later - passing in the id 
		tones.attack = 20;
		tones.type = Tones.OscillatorType.SQUARE;
		var noteId = tones.playFrequency(110, false);
		Timer.delay(tones.releaseNote.bind(noteId), 1000);
		//*/
	}
	
	
	
	// ------------------------------------------------------------------------------------------------------
	
	
	function setupKeyboardControls():Void {
		
		keyboardNotes 	= new KeyboardNotes(1);
		keyboardInput 	= new KeyboardInput(keyboardNotes);
		noteIndexToId	= new Map<Int,Int>();
		activeKeys 		= new Array<Bool>();
		for (i in 0...256) activeKeys[i] = false;
	
		tones.type 		= Tones.OscillatorType.SAWTOOTH;
		// todo: stackoverflow.com/questions/20156888/what-are-the-parameters-for-createperiodicwave-in-google-chrome
		// http://www.sitepoint.com/using-fourier-transforms-web-audio-api/
		// https://chromium.googlecode.com/svn/trunk/samples/audio/wave-tables/
		
		// keyboard control...
		Browser.window.addEventListener('keydown', onKeyDown);
		Browser.window.addEventListener('keyup', onKeyUp);
		
		keyboardInput.noteOn.connect(handleNoteOn);
		keyboardInput.noteOff.connect(handleNoteOff);
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
		var f = keyboardNotes.noteIndexToFrequency(index);
		tones.volume   = .2;
		//tones.type 		= Tones.OscillatorType.CUSTOM;
		tones.attack  = 10;
		tones.release = 1000;
		noteIndexToId.set(index, tones.playFrequency(f, false));
	}
	
	function handleNoteOff(index:Int) {
		tones.releaseNote(noteIndexToId.get(index));
		noteIndexToId.remove(index);
	}
	
	inline public function keyIsDown(code:Int):Bool return activeKeys[code];

}