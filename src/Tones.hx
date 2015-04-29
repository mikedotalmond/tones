package;
import haxe.Timer;
import js.Browser;
import js.html.audio.AudioContext;
import js.html.audio.GainNode;
import js.html.audio.OscillatorNode;

/**
 * ...
 * @author bit101 - https://github.com/bit101/tones
 * @author Mike Almond - https://github.com/mikedotalmond
 */

class Tones {
  
	var _attack	:Float;
	var _release:Float;
	var _volume	:Float;
	
	public var context(default, null):AudioContext;
	public var type(default, default):OscillatorType;
	
	public var attack(get, set):Float;
	public var release(get, set):Float;
	public var volume(get, set):Float;
	
	
	public function new() {
		
		context = untyped __js__('new (window.AudioContext || window.webkitAudioContext)()');
		type	= OscillatorType.SINE;
		attack 	= 1.0;
		release = 100.0;
		volume 	= .25;
		
		// need to create a node in order to kick off the timer in Chrome.
		context.createGain();
	}
	
	
	/**
	 * Play a note using the supplied data - could be used for some rough sequencing
	 * @param	playData
	 */
    public function play(playData:PlayData):Void {
		volume 	= playData.volume;
		attack 	= playData.attack;
		release = playData.release;
		type 	= playData.type;
		playFrequency(playData.freq);
	}
	
	
	/**
	 * Play a frequency
	 * notes.playFrequency(440); // plays a 440 Hz tone
	 *
	 * @param	freq
	 */
    public function playFrequency(freq:Float):Void {
	   
		var nowTime = now();
		var envelope = context.createGain();
		envelope.gain.setValueAtTime(volume, nowTime);
		envelope.connect(context.destination, 0);
		
		envelope.gain.setValueAtTime(0, nowTime);
		envelope.gain.setTargetAtTime(volume, nowTime, attack / 1000);
		
		var osc = context.createOscillator();
		osc.frequency.setValueAtTime(freq, nowTime);
		osc.type = cast type;
		osc.connect(envelope, 0);
		osc.start(nowTime);
		
		envelope.gain.setTargetAtTime(0, nowTime + attack / 1000, release / 1000);
		Timer.delay(afterRelease.bind(osc, envelope), Std.int(attack * 10 + release * 10));
	}
	
	
	/** 
	 * Usage: 
	 * notes.playNote("c");     // plays note c in default 4th octave
	 * notes.playNote("c#");    // plays note c sharp in default 4th octave
	 * notes.playNote("eb");    // plays note e flat in default 4th octave
	 * notes.playNote("c", 2);  // plays note c in 2nd octave
	 */
	public function playNote(noteName:String, octave:Int = 4) {
		if (octave < 0) octave = 0;
		else if (octave > 9) octave = 9;
		playFrequency(noteMap[octave].get(noteName.toLowerCase()));
	}
	
	
	/**
	 * Stop and disconnect nodes after release completes
	 * @param	osc
	 * @param	env
	 */
	function afterRelease(osc:OscillatorNode, env:GainNode) {
		osc.stop(0);
		osc.disconnect(0);
		env.gain.cancelScheduledValues(0);
		env.disconnect(0);
	}

	
	/**
	 * The current audio-context time
	 * @return
	 */
	inline public function now():Float return context.currentTime;
	
    
	// get / set
	
	inline function get_attack():Float return _attack;
	function set_attack(value:Float):Float {
		if (value < 1) value = 1;
		return _attack = value;
	}
	
	inline function get_release():Float return _release;
	function set_release(value:Float):Float {
		if (value < 1) value = 1;
		return _release = value;
	}
	
	inline function get_volume():Float return _volume;
	function set_volume(value:Float):Float {
		if (value < 0) value = 0;
		else if (value > 1) value = 1;
		return _volume = value;
	}
	
	
	/**
	 * todo 	perhaps allow users to generate this data programatically so other tunings can be used... not a priority really.
	 * @param 	name   Note name, is case insensitive - eg "c#", "g", "A" "Bb" "eb"
	 * @param 	octave Int in range of 0-9
	 */
	public static function getNoteFreq(name:String, octave:Int=4) return noteMap[octave].get(name.toLowerCase());
	
    static var noteMap:Array<Map<String,Float>> = 
	[ // octaves 0-9
		["c" => 16.351, "c#" => 17.324, "db" => 17.324, "d" => 18.354, "d#" => 19.445, "eb" => 19.445, "e" => 20.601, "f" => 21.827, "f#" => 23.124, "gb" => 23.124, "g" => 24.499, "g#" => 25.956, "ab" => 25.956, "a" => 27.5, "a#" => 29.135, "bb" => 29.135, "b" => 30.868],
		["c" => 32.703, "c#" => 34.648,	"db" => 34.648, "d" => 36.708, "d#" => 38.891, "eb" => 38.891,	"e" => 41.203, "f" => 43.654, "f#" => 46.249, "gb" => 46.249, "g" => 48.999, "g#" => 51.913,	"ab" => 51.913, "a" => 55, "a#" => 58.27, "bb" => 58.27, "b" => 61.735],
		["c"=> 65.406, "c#"=> 69.296, "db"=> 69.296, "d"=> 73.416, "d#"=> 77.782, "eb"=> 77.782, "e"=> 82.407, "f"=> 87.307, "f#"=> 92.499, "gb"=> 92.499, "g"=> 97.999, "g#"=> 103.826, "ab"=> 103.826, "a"=> 110, "a#"=> 116.541, "bb"=> 116.541, "b"=> 123.471], 
		["c"=> 130.813, "c#"=> 138.591, "db"=> 138.591, "d"=> 146.832, "d#"=> 155.563, "eb"=> 155.563, "e"=> 164.814, "f"=> 174.614, "f#"=> 184.997, "gb"=> 184.997, "g"=> 195.998, "g#"=> 207.652, "ab"=> 207.652, "a"=> 220, "a#"=> 233.082, "bb"=> 233.082, "b"=> 246.942],
		["c" => 261.626, "c#" => 277.183, "db" => 277.183, "d" => 293.665, "d#" => 311.127, "eb" => 311.127, "e" => 329.628, "f" => 349.228, "f#" => 369.994, "gb" => 369.994, "g" => 391.995, "g#" => 415.305, "ab" => 415.305, "a" => 440, "a#" => 466.164, "bb" => 466.164, "b" => 493.883],
		["c"=> 523.251, "c#"=> 554.365, "db"=> 554.365, "d"=> 587.33, "d#"=> 622.254, "eb"=> 622.254, "e"=> 659.255, "f"=> 698.456, "f#"=> 739.989, "gb"=> 739.989, "g"=> 783.991, "g#"=> 830.609, "ab"=> 830.609, "a"=> 880, "a#"=> 932.328, "bb"=> 932.328, "b"=> 987.767],
		["c"=> 1046.502, "c#"=> 1108.731, "db"=> 1108.731, "d"=> 1174.659, "d#"=> 1244.508, "eb"=> 1244.508, "e"=> 1318.51, "f"=> 1396.913, "f#" => 1479.978, "gb" => 1479.978, "g" => 1567.982, "g#" => 1661.219, "ab" => 1661.219, "a" => 1760, "a#" => 1864.655, "bb" => 1864.655, "b"=> 1975.533],
		["c" => 2093.005, "c#" => 2217.461, "db" => 2217.461, "d" => 2349.318, "d#" => 2489.016, "eb" => 2489.016, "e" => 2637.021, "f" => 2793.826, "f#"=> 2959.955, "gb"=> 2959.955, "g"=> 3135.964, "g#"=> 3322.438, "ab"=> 3322.438, "a"=> 3520, "a#"=> 3729.31, "bb"=> 3729.31, "b"=> 3951.066],
		["c"=> 4186.009, "c#"=> 4434.922, "db"=> 4434.922, "d"=> 4698.636, "d#"=> 4978.032, "eb"=> 4978.032, "e"=> 5274.042, "f"=> 5587.652, "f#"=> 5919.91, "gb"=> 5919.91, "g"=> 6271.928, "g#"=> 6644.876, "ab"=> 6644.876, "a"=> 7040, "a#"=> 7458.62, "bb"=> 7458.62, "b"=> 7902.132],
		["c" => 8372.018, "c#" => 8869.844, "db" => 8869.844, "d" => 9397.272, "d#" => 9956.064, "eb" => 9956.064, "e" => 10548.084, "f" => 11175.304,  "f#" => 11839.82, "gb" => 11839.82, "g" => 12543.856, "g#" => 13289.752, "ab" => 13289.752, "a" => 14080, "a#" => 14917.24, "bb" => 14917.24, "b" => 15804.264]
	];
}


typedef PlayData = {
	var volume	:Float;
	var attack	:Float;
	var release	:Float;
	var type	:OscillatorType;
	var freq	:Float;
}

@:native("window.OscillatorTypeShim")
extern enum OscillatorType {
	SINE; 
	SQUARE; 
	TRIANGLE; 
	SAWTOOTH; 
	CUSTOM;
}

@:keep @:noCompletion class OscillatorTypeShim {	
	static function __init__() {
		// init shim -- fix for differences in current browser versions
		var node:Dynamic = untyped __js__('window.OscillatorNode');
		if (node != null) {
			if (Reflect.hasField(node, "SINE")) {
				// older chrome/webkit
				untyped __js__('window.OscillatorTypeShim = {SINE:node.SINE, SQUARE:node.SQUARE, TRIANGLE:node.TRIANGLE, SAWTOOTH:node.SAWTOOTH, CUSTOM:node.CUSTOM}');
			} else {
				// firefox/geko
				untyped __js__('window.OscillatorTypeShim = {SINE:"sine", SQUARE:"square", TRIANGLE:"triangle", SAWTOOTH:"sawtooth", CUSTOM:"custom"}');
			}
		}
	}
}