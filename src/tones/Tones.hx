package tones;

import haxe.Timer;
import js.Browser;

import js.html.audio.AudioContext;
import js.html.audio.AudioNode;
import js.html.audio.GainNode;
import js.html.audio.OscillatorNode;

#if (haxe_ver <= 3.103)
typedef PeriodicWave = js.html.audio.WaveTable;
#else
import js.html.audio.PeriodicWave;
#end

/**
 * ...
 * @author bit101 - https://github.com/bit101/tones
 * @author Mike Almond - https://github.com/mikedotalmond
 */

class Tones {
  
	static inline var TimeConstDivider = 4.605170185988092; // Math.log(100);
	static inline function getTimeConstant(time:Float) return Math.log(time + 1.0) / TimeConstDivider;
	static inline function rExp(v) return 1.0 - 1.0 / Math.exp(v);
	static inline function isFirefox() return Browser.navigator.userAgent.indexOf('Firefox') > -1;
	
	public static function createContext():AudioContext {
		return untyped __js__('new (window.AudioContext || window.webkitAudioContext)()');
	}
	
	
	public var context(default, null):AudioContext;
	public var destination(default, null):AudioNode;
	
	public var activeNotes(default, null):Map<Int, Note>;
	
	public var type:OscillatorType;	
	public var customWave:PeriodicWave = null;
	
	public var attack(get, set):Float; // milliseconds
	public var release(get, set):Float; // milliseconds
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
		
		// Hmm - Firefox (dev) appears to need the setTargetAtTime time to be a bit in the future for it to work in the release phase.
		// (apparently about 4096 samples worth of data (1 buffer perhaps?))
		// If I use context.currentTime the setTargetAtTime will not fade-out, it just ends aruptly.  
		// Even with this delay in place it's still occasionaly glitchy...
		// Works fine in Chrome
		releaseFudge = isFirefox() ? (4096 / context.sampleRate) : 0;
		
		// set some reasonable defaults
		type 	= OscillatorType.SINE;
		attack 	= 10.0;
		release = 100.0;
		volume 	= .1;
	}
	
	
	/**
	 * Play a frequency
	 * notes.playFrequency(440); // plays a 440 Hz tone
	 * notes.playFrequency(440, 1); // plays a 440 Hz tone, in one second
	 * notes.playFrequency(440, 1, false); // plays a 440 Hz tone, in one second, and doesn't release untill you call releaseNote(noteId)
	 *
	 * @param	freq		- A frequency, expressed in Hertz, and above zero. Typically in the audible range 20Hz-20KHz
	 * @param	delayBy		- A time, in seconds, to delay triggering this note by.
	 * @param	autoRelease - Release as soon as attack phase ends - default behaviour (true)
	 * 						  when false the note will play until releaseNote(noteId) is called
	 * 						- Don't use these behaviours at the same time in one Tones instance 
	 * @return 	noteId		- The ID assigned to the note being played. Use for releaseNote() when using autoRelease=false
	 */
    public function playFrequency(freq:Float, delayBy:Float = .0, autoRelease:Bool = true):Int {
	   
		var id = ID; ID++;
		
		var attackSeconds = attack / 1000;
		
		var envelope = context.createGain();
		var triggerTime = now() + delayBy;
		var releaseTime = triggerTime + attackSeconds;
		
		envelope.gain.value = 0;
		envelope.connect(destination);
		// attack
		envelope.gain.setTargetAtTime(volume, triggerTime, getTimeConstant(attackSeconds));
		
		var osc = context.createOscillator();
		if (type == OscillatorType.CUSTOM) osc.setPeriodicWave(customWave);
		else osc.type = cast type; // firefox throws InvalidStateError if setting osc type and using setPeriodicWave 
		
		// set freq value before connecting
		osc.frequency.value = freq;
		
		osc.connect(envelope);
		osc.start(triggerTime);
		
		activeNotes.set(id, { id:id, osc:osc, env:envelope, release:release, attackEnd:triggerTime + attackSeconds } );
		polyphony++;
		
		if (autoRelease) {
			envelope.gain.setTargetAtTime(0, releaseTime, getTimeConstant(release / 1000));
			Timer.delay(stop.bind(id), Math.round(attack + release));
		}
		
		trace('On  | Polyphony:$polyphony, noteId:$id, freq:$freq, delayBy:$delayBy');
		return id;		
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
		return playFrequency(playData.freq, (playData.delay == null) ? 0 : playData.delay);
	}
	
	
	/**
	 * 
	 * @param	id
	 */
	public function releaseNote(id:Int) {
		var note = getNote(id);
		if (note == null) return;
		
		var t = now() + releaseFudge;
		var r = note.release;
		
		// attack phase has not completed, cancel it
		if (note.attackEnd > now()) note.env.gain.cancelScheduledValues(t);
		
		note.env.gain.setTargetAtTime(0, t, getTimeConstant(r / 1000));
		Timer.delay(stop.bind(id), Math.round(r));
	}
	
	
	public function releaseAll() {
		for (id in activeNotes.keys()) releaseNote(id);
	}
	
	
	public function stopAll() {
		for (id in activeNotes.keys()) stop(id);
	}
	
    
	/**
	 * Stop and disconnect nodes after release completes
	 * @param	osc
	 * @param	env
	 */
	public function stop(id:Int) {
		var note = activeNotes.get(id);
		if (note == null) return;
		
		note.osc.stop(now());
		note.osc.disconnect();
		
		note.env.gain.cancelScheduledValues(now());
		note.env.disconnect();
		
		activeNotes.remove(id);
		polyphony--;
		
		trace('Off | Polyphony:$polyphony, noteId:$id');
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
	var volume:Float;
	var attack:Float;
	var release:Float;
	var type:OscillatorType;
	var freq:Float;
	@:optional var delay:Float;
}