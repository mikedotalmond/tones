package tones.examples;

import dat.gui.GUI;
import hxsignal.Signal.ConnectionTimes;
import js.Browser;
import js.html.audio.AudioContext;
import js.html.audio.GainNode;
import js.html.KeyboardEvent;
import js.html.SelectElement;
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
	var allWaveNames:Array<String>;
	var gui:dat.gui.GUI;
	
	
	public function new() {	
		
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
		
		allWaveNames = ['Sine', 'Square', 'Sawtooth', 'Triangle'];
		
		// load some wavetables...
		wavetables = new Wavetables();
		wavetables.loadComplete.connect(wavetablesLoaded, ConnectionTimes.Once);
		
	}
	
	function wavetablesLoaded() {
		allWaveNames = allWaveNames.concat([ for (item in wavetables.data) item.name ]);
		setupUI();
	}	
	
	function setupUI() {
		
        gui = new GUI();
		
		gui.add({ volume:.5 }, 'volume', 0, 1).step(1 / 256).onChange(function(_) { outGain.gain.setValueAtTime(_, context.currentTime + .1); } );
		gui.add(keyboardInput, 'octaveShift', -1, 3).step(1).onChange(releaseAll);
		
		var folder:GUI;
		
		var rnd = gui.addFolder('Randomise');
		rnd.add( { 'All': randomise.bind('all') }, 'All');
		rnd.open();
		
		folder = rnd.addFolder('A');
		folder.add( { 'type': selectRandomOsc.bind(0) }, 'type');
		folder.add( { 'volume': randomise.bind('volume') }, 'volume');
		folder.add( { 'attack': randomise.bind('attack') }, 'attack');
		folder.add( { 'release': randomise.bind('release') }, 'release');
		
		folder = rnd.addFolder('B');
		folder.add( { 'type': selectRandomOsc.bind(1) }, 'type');
		folder.add( { 'volume': randomise.bind('volume') }, 'volume');
		folder.add( { 'attack': randomise.bind('attack') }, 'attack');
		folder.add( { 'release': randomise.bind('release') }, 'release');
		
		folder = gui.addFolder('Osc A');
		folder.add(tonesA, '_volume', 0, 1).step(1/256).listen();
		folder.add(tonesA, '_attack', 1, 2000).step(1/256).listen();
		folder.add(tonesA, '_release', 1, 2000).step(1/256).listen();
		folder.add( { waveform:'Square' }, 'waveform', allWaveNames).onChange(onWaveformSelect.bind(_, tonesA));
		folder.open();
		
		folder = gui.addFolder('Osc B');
		folder.add(tonesB, '_volume', 0, 1).step(1/256).listen();
		folder.add(tonesB, '_attack', 1, 2000).step(1/256).listen();
		folder.add(tonesB, '_release', 1, 2000).step(1/256).listen();
		folder.add( { waveform:'Square' }, 'waveform', allWaveNames).onChange(onWaveformSelect.bind(_, tonesB));
		folder.open();
	}
	
	function releaseAll() {
		tonesA.releaseAll(); tonesB.releaseAll();
	}
	
	function randomise(type:String) {
		
		releaseAll();
		
		switch(type) {
			case 'volume':
				tonesA.volume = .01 + Math.random();
				tonesB.volume = .01 + Math.random();
			case 'attack':
				tonesA.attack = Math.random() * 2000;
				tonesB.attack = Math.random() * 2000;
			case 'release':
				tonesA.release = Math.random() * 2000;
				tonesB.release = Math.random() * 2000;
			case 'all': 
				selectRandomOsc(0);
				selectRandomOsc(1);
				randomise('volume');
				randomise('attack');
				randomise('release');
		}
	}
	
	function selectRandomOsc(index:Int):Void {
		
		var selects = Browser.document.querySelectorAll('select');
		
		var i = Std.int(Math.random() * allWaveNames.length);
		onWaveformSelect(allWaveNames[i], index == 0 ? tonesA : tonesB);
		
		cast(selects.item(index), SelectElement).selectedIndex = i;
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
		trace('Oscillator set to ${value}');
	}
	
	function getWavetableDataByName(value:String):WavetableData {
		for (item in wavetables.data) {
			if (item.name == value) return item;
		}
		return null;
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