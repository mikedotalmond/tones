package tones.processor;

import js.html.audio.AudioContext;
import js.html.audio.AudioNode;
import js.html.audio.OverSampleType;
import js.html.audio.WaveShaperNode;
import js.html.Float32Array;

/**
 * ...
 * @author Mike Almond - https://github.com/mikedotalmond
 */

abstract WaveShaper(WaveShaperNode) from WaveShaperNode to WaveShaperNode {
	
	inline public function new(context:AudioContext, oversample:OverSampleType=OverSampleType.NONE, ?input:AudioNode=null, ?destination:AudioNode=null) {
		
		this = context.createWaveShaper();
		this.curve = new Float32Array(Std.int(context.sampleRate));
		
		this.oversample = oversample; // 'none','2x', '4x'
		amount = 0;
		
		if (input != null) input.connect(this);
		if (destination != null) this.connect(destination);
	}
	
	public var node(get, never):WaveShaperNode;
	inline function get_node():WaveShaperNode return this;
	
	
	/*
	 * Set the waveshaper distortion amount [-1.0 ... 1.0] 
	 * */
	public var amount(never, set):Float;
	inline function set_amount(value:Float = .0) {
		value = value < -1.0 ? -1.0 : (value > 1.0 ? 1.0 : value);
		WaveShaper.getDistortionCurve(value, this.curve);
		return value;
	}
	
	/**
	 * Distortion amount [-1.0 ... 1.0] 
	 */	
	public static function getDistortionCurve(amount:Float = .0, target:Float32Array=null):Float32Array {
		
		if (amount < -1.0 || amount > 1.0) throw "RangeError";
		
		var curve 	= target==null ? new Float32Array(44100) : target;		
		var	n 		= curve.length;
		
		var k 		= (2 * amount) / (1 - amount);
		var x;
		
		// k = 2 * amount / (1-amount);
		
		// f(x) = (1+k)*x/(1+k*abs(x))
		// f(x) = (1+k)*(x*x*x)/(1+k*abs(x*x*x))
		
		// useful - https://kevincennis.github.io/transfergraph/
		
		for (i in 0...n) {
			x 			= -1 + ((i + i) / n);
			curve[i] 	= (1 + k) * x / ( + k * Math.abs(x));
		}
		
		return curve;
	}
}