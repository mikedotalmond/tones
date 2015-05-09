package tones.examples;

import dat.gui.GUI;
import hxsignal.Signal.ConnectionTimes;
import js.Browser;
import js.html.audio.AudioContext;
import js.html.audio.GainNode;
import js.html.KeyboardEvent;
import tones.OscillatorType;
import tones.Tones;
import tones.utils.KeyboardInput;
import tones.utils.KeyboardNotes;
import tones.utils.Wavetables;


/**
 * ...
 * @author Mike Almond - https://github.com/mikedotalmond
 */

class KeyboardControlled {
	
	var tonesA			:Tones;
	var tonesB			:Tones;
	var outGain			:GainNode;
	var context			:AudioContext;
	var wavetables		:Wavetables;
	
	var keyboardNotes	:KeyboardNotes;
	var keyboardInput	:KeyboardInput;
	var noteIndexToId	:Map<Int,Int>; // For active notes - map note-index (0-128) to the Tones noteID
	var activeKeys		:Array<Bool>; // (keyboard) keyIsDown == activeKeys[keyCode]
	
	
	public function new() {	
		
		wavetables = new Wavetables();
		wavetables.loadComplete.connect(wavetablesLoaded, ConnectionTimes.Once);
		
		// share a single context across 2 tones instances
		// (could just as well be sharing with an effects library or other any other webaudio project really)
		context = Tones.createContext();
		
		// Here the destination for both Toens is a single output gain... you could just as easily route them to diffrerent destinations
		// and apply effects (dynamics, filters, spatial positioning,.. anything), to each before routing them to the destination.
		outGain = context.createGain();
		outGain.gain.value = .5;
		
		tonesA			= new Tones(context, outGain);
		tonesA.type 	= OscillatorType.SQUARE;
		tonesA.volume   = .62;
		tonesA.attack  	= 1;
		tonesA.release 	= 2000;
		
		tonesB			= new Tones(context, outGain);
		tonesB.type 	= OscillatorType.SQUARE;
		tonesB.volume   = .48;
		tonesB.attack  	= 2000;
		tonesB.release 	= 133;
		
		outGain.connect(context.destination);
		
		setupKeyboardControls();		
	}
	
	function wavetablesLoaded() {
		trace('Wavetables loaded');
		//Browser.document.addEventListener('click', onClick);
		//Browser.document.addEventListener('tap', onClick);
		setupUI();
	}
	
	
	function setupUI() {
		
        var data = { volume:.5 };
		
        var gui = new GUI();
		gui.add(data, 'volume', 0, 1).step(1 / 256).onChange(function() {
			outGain.gain.setValueAtTime(data.volume, context.currentTime + .1);
		});
		gui.add(keyboardInput, 'octaveShift', -1, 3)
			.step(1).onChange(function() { tonesA.releaseAll(); tonesB.releaseAll(); });
		
		var waveNames:Array<String> = ['Sine', 'Square', 'Sawtooth', 'Triangle'].concat([ for (item in wavetables.data) item.name ]);
		
		var folder:GUI;
		folder = gui.addFolder('Tones A');
		folder.add(tonesA, '_volume', 0, 1).step(1/256);
		folder.add(tonesA, '_attack', 1, 2000).step(1/256);
		folder.add(tonesA, '_release', 1, 2000).step(1/256);
		folder.add( { waveform:'Square' }, 'waveform', waveNames).onChange(onWaveformSelect.bind(_, tonesA));
		folder.open();
		
		folder = gui.addFolder('Tones B');
		folder.add(tonesB, '_volume', 0, 1).step(1/256);
		folder.add(tonesB, '_attack', 1, 2000).step(1/256);
		folder.add(tonesB, '_release', 1, 2000).step(1/256);
		folder.add( { waveform:'Square' }, 'waveform', waveNames).onChange(onWaveformSelect.bind(_, tonesB));
		folder.open();
	}	
	
	
	function onWaveformSelect(value:String, target:Tones) {
		switch(value) {
			case 'Sine'		: target.type = OscillatorType.SINE;
			case 'Square'	: target.type = OscillatorType.SQUARE;
			case 'Sawtooth'	: target.type = OscillatorType.SAWTOOTH;
			case 'Triangle'	: target.type = OscillatorType.TRIANGLE;
			
			default:
				var data = getWavetableDataByName(value);
				target.type = OscillatorType.CUSTOM;
				target.customWave = context.createPeriodicWave(data.real, data.imag);
		};
	}
	
	
	function getWavetableDataByName(value:String):WavetableData {
		for (item in wavetables.data) {
			if (item.name == value) return item;
		}
		return null;
	}
	
	
	function onClick(_):Void {
		var d = wavetables.data;
		
		// pick randomly from all wavetables
		
		var i = Std.int(Math.random() * d.length);
		tonesA.type = OscillatorType.CUSTOM;
		tonesA.customWave = context.createPeriodicWave(d[i].real, d[i].imag);
		trace('tonesA Oscillator changed to ${d[i].name}');
		
		// 50% of the time set a different random osc for tonesB
		if (Math.random() > .5) i = Std.int(Math.random() * d.length);
		
		tonesB.type = OscillatorType.CUSTOM;
		tonesB.customWave = context.createPeriodicWave(d[i].real, d[i].imag);
		trace('tonesB Oscillator changed to ${d[i].name}');
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
		var f2 = keyboardNotes.noteFreq.detuneFreq(f, (Math.random() -.5) * 25);
		
		var t 			= 1 / f;
		var phaseShift 	= t * (1 / (Math.random() * 6));
		
		// trigger tonesB with a little detuning and phase offset (a tiny delay) for a richer/more interesing sound
		
		noteIndexToId.set(index, tonesA.playFrequency(f, 0, false));
		noteIndexToId.set(index, tonesB.playFrequency(f2, phaseShift, false));
	}
	
	function handleNoteOff(index:Int) {
		tonesA.releaseNote(noteIndexToId.get(index));
		tonesB.releaseNote(noteIndexToId.get(index));
		noteIndexToId.remove(index);
	}
	
	inline function keyIsDown(code:Int):Bool return activeKeys[code];

}