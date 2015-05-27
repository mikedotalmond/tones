package tones.examples;

import haxe.Timer;
import hxsignal.Signal.ConnectionTimes;
import js.Browser;
import js.html.KeyboardEvent;
import js.html.MouseEvent;
import tones.utils.NoteFrequencyUtil;
import tones.utils.Wavetables;
import tones.data.OscillatorType;



/**
 * ...
 * @author Mike Almond - https://github.com/mikedotalmond
 */
class CustomWaves {
	
	var tones		:Tones;
	var wavetables	:Wavetables;

	public function new() {
		
		var p = Browser.document.createParagraphElement(); 
		p.className = "noselect";
		p.textContent = "Mousedown and move the cursor. Press any key to select a new random wavetable. Check the dev console for some stats.";
		Browser.document.body.appendChild(p);
		
		Browser.document.addEventListener('keydown', function(e:KeyboardEvent) {
			var i = Std.int(Math.random() * wavetables.data.length);
			setWave(i);
		});
		
		
		tones = new Tones();
		tones.volume = .15;
		tones.attack = .010;
		tones.release = .500;
		tones.type = OscillatorType.CUSTOM;
		
		wavetables = new Wavetables();
		wavetables.loadComplete.connect(wavetablesLoaded, ConnectionTimes.Once);
	}
	
	function wavetablesLoaded() {
		
		trace(Wavetables.FileNames);
		trace(wavetables.data);
		
		var i = Std.int(Math.random() * wavetables.data.length);
		setWave(i);
		
		Browser.document.addEventListener('mousedown', onMouse); 
		Browser.document.addEventListener('mouseup', onMouse); 
		Browser.document.addEventListener('mousemove', onMouse); 
	}
	
	function setWave(index:Int) {
		var data = wavetables.data[index];
		trace('set wavetable to ${data.name}');
		tones.customWave = tones.context.createPeriodicWave(data.real, data.imag);
	}
	
	var lastTime:Float = 0;
	var mouseIsDown:Bool = false;
	function onMouse(e:MouseEvent):Void {
		switch(e.type) {
			case 'mousedown':mouseIsDown = true;
			case 'mouseup':mouseIsDown = false;
			case 'mousemove':
				if (mouseIsDown) {
					// hmm, it's pretty fast when playing on mousemove with no rate limit - not unlike granular synthesis.
					// maybe worth making a granular resynth/sample player. they're always fun.
					var now = Timer.stamp();
					var dt = now - lastTime;
					
					if (dt > .05) { // limit playback rate a little...
						lastTime = now;
					
						tones.volume = (e.clientY / Browser.window.innerHeight) * .2;
						
						var f = 50 + 750 * (e.clientX / Browser.window.innerWidth);
						f = f < 20 ? 20 : f;
						
						tones.playFrequency(f);
						tones.playFrequency(NoteFrequencyUtil.detuneFreq(f * 2, (Math.random()-.5) * 50));
						
					}
				}

		}
	}
}