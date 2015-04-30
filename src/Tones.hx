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
  
	static var ID:Int = 0;
	
	static inline var TimeConstDivider = 4.605170185988092; // Math.log(100);
	static inline function getTimeConstant(time:Float) return Math.log(time + 1.0) / TimeConstDivider;
	static inline function rExp(v) return 1.0 - 1.0 / Math.exp(v);
	
	
	public var activeNotes(default, null):Map<Int, Note>;
	
	public var context(default, null):AudioContext;
	public var type(default, default):OscillatorType;
	
	public var attack(get, set):Float;
	public var release(get, set):Float;
	public var volume(get, set):Float;
	
	public var polyphony(default, null):Int;
	
	var _attack	:Float;
	var _release:Float;
	var _volume	:Float;
	
	public function new() {
		
		context = untyped __js__('new (window.AudioContext || window.webkitAudioContext)()');
		type = OscillatorType.SINE;
		attack = 1.0;
		release = 100.0;
		volume = .125;
		polyphony = 0;
		activeNotes = new Map<Int, Note>();
		
		// need to create a node in order to kick off the timer in Chrome.
		context.createGain();
	}
	
	
	/**
	 * Play a frequency
	 * notes.playFrequency(440); // plays a 440 Hz tone
	 *
	 * @param	freq
	 * @return 	ID - note id
	 */
    public function playFrequency(freq:Float):Int {
	   
		var nowTime = now();
		var envelope = context.createGain();
		var releaseTime = nowTime + (attack / 1000);
		
		envelope.gain.value = 0;
		envelope.connect(context.destination, 0);
		
		envelope.gain.setTargetAtTime(volume, nowTime, getTimeConstant(attack / 1000) );
		envelope.gain.setValueAtTime(volume, releaseTime);
		
		var osc = context.createOscillator();
		osc.frequency.setValueAtTime(freq, nowTime);
		osc.type = cast type;
		osc.connect(envelope, 0);
		osc.start(nowTime);
		
		activeNotes.set(ID, {id:ID, osc:osc, env:envelope} );
	
		//if (release > 0) { // todo: allow setting release later... hold notes
			envelope.gain.setTargetAtTime(0, releaseTime, getTimeConstant(release / 1000));
			Timer.delay(afterRelease.bind(ID), Math.round(attack + release));
		//}
		
		polyphony++;
		
		trace('on polyphony:$polyphony, id:$ID');
		return ++ID;		
	}
	
	
	/**
	 * Play a note using the supplied data - could be used for some rough sequencing
	 * @param	playData
	 * @return 	ID - note id
	 */
    public function play(playData:PlayData):Int {
		volume 	= playData.volume;
		attack 	= playData.attack;
		release = playData.release;
		type 	= playData.type;
		return playFrequency(playData.freq);
	}
	
	
	/**
	 * 
	 * @param	id
	 * @return	Note
	 */
	inline public function getNote(id:Int):Note return activeNotes.get(id);
	
	
	/**
	 * The current audio-context time
	 * @return
	 */
	inline public function now():Float return context.currentTime;
	
    
	/**
	 * Stop and disconnect nodes after release completes
	 * @param	osc
	 * @param	env
	 */
	function afterRelease(id:Int) {
		var note = activeNotes.get(id);
		
		note.osc.stop(now());
		note.osc.disconnect(0);
		note.env.gain.cancelScheduledValues(now());
		note.env.disconnect(0);
		
		activeNotes.remove(id);
		
		polyphony--;
		
		trace('off polyphony:$polyphony, id:$id');
	}

	
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
}


typedef Note = {
	var id:Int;
	var osc:OscillatorNode;
	var env:GainNode;
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