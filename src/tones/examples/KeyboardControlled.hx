package tones.examples;

import js.Browser;
import js.html.audio.AudioContext;
import js.html.audio.GainNode;

import tones.Tones;
import tones.OscillatorType;

import js.html.KeyboardEvent;

import tones.utils.KeyboardInput;
import tones.utils.KeyboardNotes;


/**
 * ...
 * @author Mike Almond - https://github.com/mikedotalmond
 */
class KeyboardControlled {
	
	var tonesA			:Tones;
	var tonesB			:Tones;
	
	var keyboardNotes	:KeyboardNotes;
	var keyboardInput	:KeyboardInput;
	
	// keyboard - keyIsDown == activeKeys[keyCode]
	var activeKeys		:Array<Bool>;
	
	// For active notes - map note-index (0-128) to the Tones noteID
	var noteIndexToId	:Map<Int,Int>;
	
	var outGain	:GainNode;
	var context	:AudioContext;
	
	
	public function new() {	
		
		context = Tones.createContext();
		
		outGain = context.createGain();
		outGain.gain.value = .5;
		
		tonesA			= new Tones(context, outGain);
		tonesA.type 	= OscillatorType.SAWTOOTH;
		tonesA.volume   = .2;
		tonesA.attack  	= 10;
		tonesA.release 	= 250;
		
		tonesB			= new Tones(context, outGain);
		tonesB.type 	= OscillatorType.SQUARE;
		tonesB.volume   = .3;
		tonesB.attack  	= 250;
		tonesB.release 	= 1000;
		
		outGain.connect(context.destination);
		
		setupKeyboardControls();		
	}
	
	
	// ------------------------------------------------------------------------------------------------------
	
	
	function setupKeyboardControls():Void {
		
		keyboardNotes 	= new KeyboardNotes(0);
		keyboardInput 	= new KeyboardInput(keyboardNotes);
		noteIndexToId	= new Map<Int,Int>();
		activeKeys 		= new Array<Bool>();
		for (i in 0...256) activeKeys[i] = false;
		
		keyboardInput.octaveShift = 1;
		
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
		var f2 = keyboardNotes.noteFreq.detuneFreq(f, (Math.random() -.5) * 50);
		
		noteIndexToId.set(index, tonesA.playFrequency(f, false));
		noteIndexToId.set(index, tonesB.playFrequency(f2, false));
	}
	
	function handleNoteOff(index:Int) {
		tonesA.releaseNote(noteIndexToId.get(index));
		tonesB.releaseNote(noteIndexToId.get(index));
		noteIndexToId.remove(index);
	}
	
	inline public function keyIsDown(code:Int):Bool return activeKeys[code];

}