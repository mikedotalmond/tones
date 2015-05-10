package tones.examples;

import hxsignal.Signal.ConnectionTimes;

import js.Browser;
import js.html.audio.PeriodicWave;
import js.html.MouseEvent;

import tones.OscillatorType;
import tones.utils.Wavetables;

/**
 * ...
 * @author Mike Almond - https://github.com/mikedotalmond
 */
class CustomWaves {
	
	var tones		:Tones;
	var wavetables	:Wavetables;

	public function new() {
		
		tones = new Tones();
		tones.volume = .2;
		tones.attack = 100;
		tones.release = 750;
		tones.type = OscillatorType.CUSTOM;
		
		wavetables = new Wavetables();
		wavetables.loadComplete.connect(wavetablesLoaded, ConnectionTimes.Once);
		
	}
	
	function wavetablesLoaded() {
		
		trace(Wavetables.FileNames);
		trace(wavetables.data);
		
		var i = Std.int(Math.random() * wavetables.data.length);
		setWave(i);
		
		tones.playFrequency(880);
		tones.playFrequency(440);
		tones.playFrequency(220);
		
		Browser.document.addEventListener('mousedown', onMouse); 
		Browser.document.addEventListener('mouseup', onMouse); 
		Browser.document.addEventListener('mousemove', onMouse); 
	}
	
	function setWave(index:Int) {
		var data = wavetables.data[index];
		tones.customWave = tones.context.createPeriodicWave(data.real, data.imag);
	}
	
	var mouseIsDown:Bool = false;
	function onMouse(e:MouseEvent):Void {
		switch(e.type) {
			case 'mousedown':mouseIsDown = true;
			case 'mouseup':mouseIsDown = false;
			case 'mousemove':
				if (mouseIsDown) {
					// hmm, it's pretty fast when playing on mousemove - like granular synthesis.
					// maybe worth making a granular resynth/sample player. they're always fun.
					tones.volume = (e.clientY / Browser.window.innerHeight) * .4;
					tones.playFrequency(220 + 440 * (e.clientX / Browser.window.innerWidth));
				}

		}
		
	}
}