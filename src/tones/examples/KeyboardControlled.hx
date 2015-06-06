package tones.examples;

import dat.gui.GUI;
import hxsignal.Signal.ConnectionTimes;
import js.Browser;
import js.html.audio.AudioContext;
import js.html.audio.GainNode;
import js.html.KeyboardEvent;
import js.html.SelectElement;
import tones.data.OscillatorType;
import tones.Tones;
import tones.utils.KeyboardInput;
import tones.utils.KeyboardNotes;
import tones.utils.NoteFrequencyUtil;
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
	var allWaveNames	:Array<String>;

	var keyboardNotes	:KeyboardNotes;
	var keyboardInput	:KeyboardInput;
	var noteIndexToId	:Map<Int,Int>; // For active notes - map note-index (0-128) to the Tones noteID
	var activeKeys		:Array<Bool>; // (keyboard) keyIsDown == activeKeys[keyCode]

	var gui				:GUI;


	public function new() {

		var p = Browser.document.createParagraphElement();
		p.className = "noselect";
		p.textContent = "Play using your keyboard. Check the dev console for some stats.";
		Browser.document.body.appendChild(p);

		// share a single context across 2 tones instances
		// (could just as well be sharing with an effects library or other any other webaudio project really)
		context = AudioBase.createContext();

		// Here the destination for both Toens is a single output gain... you could just as easily route them to diffrerent destinations
		// and apply effects (dynamics, filters, spatial positioning,.. anything), to each before routing them to the destination.
		outGain = context.createGain();
		outGain.gain.value = .2;

		tonesA			= new Tones(context, outGain);
		tonesA.type 	= OscillatorType.SQUARE;
		tonesA.volume   = .62;
		tonesA.attack  	= 0;
		tonesA.release 	= 2;

		tonesB			= new Tones(context, outGain);
		tonesB.type 	= OscillatorType.SQUARE;
		tonesB.volume   = .48;
		tonesB.attack  	= 2;
		tonesB.release 	= .133;

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

        gui = new GUI({autoPlace:false});

		gui.add({ volume:outGain.gain.value }, 'volume', 0, 1).step(1 / 256).onChange(function(_) { outGain.gain.setValueAtTime(_, context.currentTime + .1); } );
		gui.add(keyboardInput, 'octaveShift', -1, 3).step(1).onChange(releaseAll);

		var folder:GUI;
		var folder2:GUI;

		gui.add( { 'Randomise all': randomise.bind(-1, 'all') }, 'Randomise all');
		//rnd.open();

		folder = gui.addFolder('Osc A');
		folder2 = folder.addFolder('Randomise');
		folder.add(tonesA, '_volume', 0, 1).listen();
		folder.add(tonesA, '_attack', .0001, 2).listen();
		folder.add(tonesA, '_release', .0001, 2).listen();
		folder.add( { waveform:'Square' }, 'waveform', allWaveNames).onChange(onWaveformSelect.bind(_, tonesA));
		folder.open();

		folder2.add( { 'all': randomise.bind(0, 'all') }, 'all');
		folder2.add( { 'type': selectRandomOsc.bind(0) }, 'type');
		folder2.add( { 'volume': randomise.bind(0,'volume') }, 'volume');
		folder2.add( { 'attack': randomise.bind(0,'attack') }, 'attack');
		folder2.add( { 'release': randomise.bind(0,'release') }, 'release');

		folder = gui.addFolder('Osc B');
		folder2 = folder.addFolder('Randomise');
		folder.add(tonesB, '_volume', .0001, 1).listen();
		folder.add(tonesB, '_attack', .0001, 2).listen();
		folder.add(tonesB, '_release', .0001, 2).listen();
		folder.add( { waveform:'Square' }, 'waveform', allWaveNames).onChange(onWaveformSelect.bind(_, tonesB));
		folder.open();

		folder2.add( { 'all': randomise.bind(1, 'all') }, 'all');
		folder2.add( { 'type': selectRandomOsc.bind(1) }, 'type');
		folder2.add( { 'volume': randomise.bind(1,'volume') }, 'volume');
		folder2.add( { 'attack': randomise.bind(1,'attack') }, 'attack');
		folder2.add( { 'release': randomise.bind(1,'release') }, 'release');

		Browser.document.body.appendChild(gui.domElement);
	}

	function releaseAll() {
		tonesA.releaseAll(); tonesB.releaseAll();
	}

	function randomise(tIndex:Int, type:String) {

		var t = tIndex == 0 ? tonesA : tonesB;

		releaseAll();

		switch(type) {
			case 'volume':
				t.volume = .01 + Math.random();
			case 'attack':
				t.attack = Math.random() * 2;
			case 'release':
				t.release = Math.random() * 2;
			case 'all':
				if (tIndex == -1) {
					randomise(0, type);
					randomise(1, type);
				} else {
					selectRandomOsc(tIndex);
					randomise(tIndex,'volume');
					randomise(tIndex,'attack');
					randomise(tIndex,'release');
				}
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
		var f2 = NoteFrequencyUtil.detuneFreq(f, (Math.random() -.5) * 25);

		var t 			= 1 / f;
		var phaseShift 	= t * (1 / (Math.random() * 6));

		// trigger tonesB with a little detuning and phase offset (a tiny delay) for a richer/more interesing sound

		noteIndexToId.set(index, tonesA.playFrequency(f, 0, false));
		noteIndexToId.set(index, tonesB.playFrequency(f2, phaseShift, false));
		trace('note on:${keyboardNotes.noteFreq.noteIndexToName(index)}');
	}

	function handleNoteOff(index:Int) {
		tonesA.doRelease(noteIndexToId.get(index));
		tonesB.doRelease(noteIndexToId.get(index));
		noteIndexToId.remove(index);
		trace('note off:${keyboardNotes.noteFreq.noteIndexToName(index)}');
	}

	inline function keyIsDown(code:Int):Bool return activeKeys[code];
}