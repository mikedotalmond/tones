package tones.examples;

import haxe.Constraints.FlatEnum;
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
	var osc1:OscillatorNode;
	var osc2:OscillatorNode;
	var osc3:OscillatorNode;
	
	public function new() {
		
		lorenz = new Lorenz();
		minMax = new Float32Array([
			Math.POSITIVE_INFINITY, Math.NEGATIVE_INFINITY, //x
			Math.POSITIVE_INFINITY, Math.NEGATIVE_INFINITY, //y
			Math.POSITIVE_INFINITY, Math.NEGATIVE_INFINITY, //z
		]);
	
		tones = new Tones(); // create 
		
		tones.toneBegin.connect(onToneStart);
		
		// change some settings...
		tones.type = OscillatorType.SQUARE;
		tones.volume = .025;
		tones.attack = 250;
		
		tones.playFrequency(20, .5, false);
		tones.playFrequency(40, .5, false);
		tones.playFrequency(80, .5, false);
	}
	
	
	function enterFrame(time:Float) {
		Browser.window.requestAnimationFrame(enterFrame);
		
		var dt = time - lastTime;
		lastTime = time;
		
		if (dt == 0) return;
		
		var dtSecs = dt / 1000;
		
		lorenz.step(1 / 120);
		
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
		
		if (x < 0 || Math.isNaN(x)) x = 0; // clamp for rounding errors
		if (y < 0) y = 0;
		if (z < 0 || !Math.isFinite(z)) z = 0;
		
		//trace('$x,$y,$z');
		var now = tones.context.currentTime;
		osc1.frequency.cancelScheduledValues(now);
		osc2.frequency.cancelScheduledValues(now);
		osc3.frequency.cancelScheduledValues(now);
		
		var tc = Tones.getTimeConstant(dtSecs);
		
		osc1.frequency.setTargetAtTime(20 + x * 440, now, tc);
		osc2.frequency.setTargetAtTime(20 + y * 440, now, tc);
		osc3.frequency.setTargetAtTime(20 + z * 440, now, tc);
	}
	
	
	function onToneStart(id, poly) {
		if (poly == 3) {
			osc1 = tones.getToneData(0).osc;
			osc2 = tones.getToneData(1).osc;
			osc3 = tones.getToneData(2).osc;
			Browser.window.requestAnimationFrame(enterFrame);
		}
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
	
	public var x(default, null):Float;
	public var y(default, null):Float;
	public var z(default, null):Float;
	
	public function new() {
		sigma = 10.0;
		rho = 28.0;
		beta = 8 / 3;
		
		x = 1; y = 1; z = 1;
	}
	
	//https://dl.dropboxusercontent.com/u/7851949/lorenz-attractor/index.html
	public function step(dt:Float=1/120) {
		x = x + dt * (sigma * (y - x));
		y = y + dt * (x * (rho - z) - y);
		z = z + dt * (x * y - beta * z);
	}
}