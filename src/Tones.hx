package;
import haxe.Timer;
import js.Browser;
import js.html.audio.AudioContext;
import js.html.audio.AudioNode;
import js.html.audio.GainNode;
import js.html.audio.OscillatorNode;

/**
 * ...
 * @author bit101 - https://github.com/bit101/tones
 * @author Mike Almond - https://github.com/mikedotalmond
 */

class Tones {
  
	static inline var TimeConstDivider = 4.605170185988092; // Math.log(100);
	static inline function getTimeConstant(time:Float) return Math.log(time + 1.0) / TimeConstDivider;
	static inline function rExp(v) return 1.0 - 1.0 / Math.exp(v);
	
	public static function createContext():AudioContext {
		return untyped __js__('new (window.AudioContext || window.webkitAudioContext)()');
	}
	
	public static inline function isFirefox() return Browser.navigator.userAgent.indexOf('Firefox') > -1;
	
	
	public var context(default, null):AudioContext;
	public var destination(default, null):AudioNode;
	
	public var activeNotes(default, null):Map<Int, Note>;
	
	public var type:OscillatorType;
	public var attack(get, set):Float;
	public var release(get, set):Float;
	public var volume(get, set):Float;
	
	public var polyphony(default, null):Int;
	
	var ID:Int = 0;
	var _attack:Float;
	var _release:Float;
	var _volume:Float;
	var releaseFudge:Float;
	
	/**
	 * @param	audioContext 	- optional. Pass an exsiting audioContext here to share it.
	 * @param	destinationNode - optional. Pass a custom destination AudioNode to connect to.
	 */
	public function new(audioContext:AudioContext = null, ?destinationNode:AudioNode = null) {
		
		if (audioContext == null) {
			context = Tones.createContext();
		} else {
			context = audioContext;
		}
		
		if (destinationNode == null) destination = context.destination;
		else destination = destinationNode;
		
		polyphony = 0;
		activeNotes = new Map<Int, Note>();
		
		// Hmm - Firefox (dev) appears to need the setTargetAtTime time to be a bit in the future for it to work...
		// If I use context.currentTime and setTargetAtTime will not fade, it just ends aruptly. 
		// Even with this delay it's a bit glitchy occasionally
		// Works fine in Chrome 
		releaseFudge = isFirefox() ? (4096 / context.sampleRate) : 0;
	
		// set some reasonable defaults
		type 	= OscillatorType.SINE;
		attack 	= 5.0;
		release = 100.0;
		volume 	= .1;
	}
	
	
	/**
	 * Play a frequency
	 * notes.playFrequency(440); // plays a 440 Hz tone
	 *
	 * @param	freq
	 * @param	autoRelease - release as soon as attack phase ends - default behaviour (true)
	 * 						- when false the note will play until releaseNote(noteId) is called
	 * 						- Don't use these behaviours at the same time in one Tones instance 
	 * @return 	noteId
	 */
    public function playFrequency(freq:Float, autoRelease:Bool=true):Int {
	   
		var id = ID;
		ID++;
		
		var attackSeconds = attack / 1000;
		
		var nowTime = now();
		var envelope = context.createGain();
		var releaseTime = nowTime + attackSeconds;
		
		envelope.gain.value = 0;
		envelope.connect(destination, 0);
		// attack
		envelope.gain.setTargetAtTime(volume, nowTime, getTimeConstant(attackSeconds));
		
		var osc = context.createOscillator();
		osc.frequency.setValueAtTime(freq, nowTime);
		osc.type = cast type;
		osc.connect(envelope, 0);
		osc.start(nowTime);
		
		activeNotes.set(id, { id:id, osc:osc, env:envelope, release:release, attackEnd:nowTime + attackSeconds } );
		polyphony++;
		
		if (autoRelease) {
			envelope.gain.setTargetAtTime(0, releaseTime, getTimeConstant(release / 1000));
			Timer.delay(afterRelease.bind(id), Math.round(attack + release));
		}
		
		trace('On  | Polyphony:$polyphony, noteId:$id, freq:$freq');
		return id;		
	}
	
	
	public function releaseNote(id:Int) {
		var note = getNote(id);
		if (note == null) return;
		
		var t = now() + releaseFudge;
		var r = note.release;
		
		// attack phase has not completed, cancel it
		if (note.attackEnd > now()) note.env.gain.cancelScheduledValues(t);
		
		note.env.gain.setTargetAtTime(0, t, getTimeConstant(r / 1000));
		Timer.delay(afterRelease.bind(id), Math.round(r));
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
		if (note == null) return;
		
		note.osc.stop(now());
		note.osc.disconnect(0);
		
		note.env.gain.cancelScheduledValues(now());
		note.env.disconnect(0);
		
		activeNotes.remove(id);
		polyphony--;
		
		trace('Off | Polyphony:$polyphony, noteId:$id');
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
	var attackEnd:Float;
	var release:Float;
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