package tones.examples;

import dat.gui.GUI;
import js.html.audio.GainNode;
import js.html.audio.OscillatorNode;
import js.html.Float32Array;
import js.Browser;
import tones.Tones;

/**
 * ...
 * @author Mike Almond - https://github.com/mikedotalmond
 */
class LorenzTones {
	
	var tones:Tones;
	var lorenz:Lorenz;
	var minMax:Float32Array;
	
	var lastTime:Float =0;
	var masterGain:GainNode;
	var osc1:OscillatorNode;
	var osc2:OscillatorNode;
	var osc3:OscillatorNode;
	var speed:Int;
	var gui:GUI;
	
	var freqLow:Float;
	var freqHigh:Float;
	
	public function new() {
		
		speed = 16;
		freqLow = 80;
		freqHigh = 220;
		lorenz = new Lorenz();
		minMax = new Float32Array([
			Math.POSITIVE_INFINITY, Math.NEGATIVE_INFINITY, //x
			Math.POSITIVE_INFINITY, Math.NEGATIVE_INFINITY, //y
			Math.POSITIVE_INFINITY, Math.NEGATIVE_INFINITY, //z
		]);
	
		var c = Tones.createContext();
		
		masterGain = c.createGain();
		masterGain.gain.value = .75;
		masterGain.connect(c.destination);
		
		tones = new Tones(c, masterGain); 
		tones.toneBegin.connect(onToneStart);
		
		// change some settings...
		tones.type = OscillatorType.TRIANGLE;
		tones.volume = .2;
		tones.attack = .250;
		
		tones.playFrequency(40, .5, false);
		tones.playFrequency(40, .5, false);
		tones.playFrequency(40, .5, false);
		
		setupUI();
	}
	
	function onToneStart(id, time) {
		if (tones.polyphony == 3) {
			osc1 = tones.getToneData(0).osc;
			osc2 = tones.getToneData(1).osc;
			osc3 = tones.getToneData(2).osc;
			Browser.window.requestAnimationFrame(enterFrame);
		}
	}
	
	function enterFrame(time:Float) {
		Browser.window.requestAnimationFrame(enterFrame);
		
		var dt = time - lastTime;
		lastTime = time;
		
		if (dt == 0) return;
		
		for(i in 0...speed) lorenz.step(1 / 1280);
		
		
		var lx = lorenz.x; var ly = lorenz.y; var lz = lorenz.z;
		minMax[0] = Math.min(minMax[0], lx);
		minMax[1] = Math.max(minMax[1], lx);
		minMax[2] = Math.min(minMax[2], ly);
		minMax[3] = Math.max(minMax[3], ly);
		minMax[4] = Math.min(minMax[4], lz);
		minMax[5] = Math.max(minMax[5], lz);
		
		var x = (lx - minMax[0]) / (minMax[1] - minMax[0]);
		var y = (ly - minMax[2]) / (minMax[3] - minMax[2]);
		var z = (lz - minMax[4]) / (minMax[5] - minMax[4]);
		
		if (x < 0 || Math.isNaN(x)) x = 0; 
		if (y < 0 || Math.isNaN(y)) y = 0;
		if (z < 0 || !Math.isFinite(z)) z = 0;
		
		//trace('$x,$y,$z');
		var now = tones.context.currentTime;
		osc1.frequency.cancelScheduledValues(now);
		osc2.frequency.cancelScheduledValues(now);
		osc3.frequency.cancelScheduledValues(now);
		
		var range = (freqHigh - freqLow);
		var tc = Tones.getTimeConstant(dt / 1000);
		osc1.frequency.setTargetAtTime(freqLow + x * range, now, tc);
		osc2.frequency.setTargetAtTime(freqLow + y * range, now, tc);
		osc3.frequency.setTargetAtTime(freqLow + z * range, now, tc);
	}
	
	
	function setupUI() {
		gui = new GUI({autoPlace:false});
		gui.add({ volume: masterGain.gain.value }, 'volume', 0, 1).step(1 / 256).onChange(function(_) { masterGain.gain.setValueAtTime(_, tones.context.currentTime + .1); } );
		gui.add(this, 'speed', 1, 128).step(1);
		gui.add(this, 'freqLow', 20, 440);
		gui.add(this, 'freqHigh', 20, 440);
		Browser.document.body.appendChild(gui.domElement);
	}
}


/**
 * ...
 * @author Mike Almond - https://github.com/mikedotalmond
 */
class Lorenz {
	
	public var sigma:Float;
    public var rho:Float;
    public var beta:Float;
	
	public var x(get, never):Float;
	inline function get_x() return xyz[0];
	
	public var y(get, never):Float;
	inline function get_y() return xyz[1];
	
	public var z(get, never):Float;
	inline function get_z() return xyz[2];
	
	var xyz:Float32Array;
	
	public function new() {
		sigma 	= 10.0;
		rho 	= 28.0;
		beta 	= 8 / 3;
		xyz 	= new Float32Array([1.0, 1.0, 1.0]);
	}
	
	public function reset() {
		xyz[0] = 1.0; xyz[1] = 1.0; xyz[2] = 1.0;
	}
	
	public function step(dt:Float=1/120) {
		xyz[0] = xyz[0] + dt * (sigma * (xyz[1] - xyz[0]));
		xyz[1] = xyz[1] + dt * (xyz[0] * (rho - z) - xyz[1]);
		xyz[2] = xyz[2] + dt * (xyz[0] * xyz[1] - beta * xyz[2]);
	}
}