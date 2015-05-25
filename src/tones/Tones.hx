package tones;

import haxe.Timer;
import hxsignal.Signal;
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
  
	static public inline var TimeConstDivider = 4.605170185988092; // Math.log(100);
	static public inline function getTimeConstant(time:Float) return Math.log(time + 1.0) / TimeConstDivider;
	
	static inline function isFirefox() return Browser.navigator.userAgent.indexOf('Firefox') > -1;
	
	public static function createContext():AudioContext {
		return untyped __js__('new (window.AudioContext || window.webkitAudioContext)()');
	}
	
	
	public var context(default, null):AudioContext;
	public var destination(default, null):AudioNode;
	
	
	public var type:OscillatorType;	
	public var customWave:PeriodicWave = null;
	
	public var attack	(get, set):Float; // seconds
	public var release	(get, set):Float; // seconds
	public var volume	(get, set):Float;
	
	public var polyphony	(default, null):Int;
	public var activeTones	(default, null):Map<Int, ToneData>;
	public var toneBegin	(default, null):Signal<Int->Int->Void>;
	public var toneEnd		(default, null):Signal<Int->Int->Void>;
	public var toneReleased	(default, null):Signal<Int->Void>;
	
	
	var ID:Int = 0;
	var _attack:Float;
	var _release:Float;
	var _volume:Float;
	var releaseFudge:Float;
	
	var delayedBegin:Array<{id:Int, time:Float}>;
	var delayedRelease:Array<{id:Int, time:Float}>;
	var delayedEnd:Array<{id:Int, time:Float}>;
	
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
		
		delayedBegin = [];
		delayedRelease = [];
		delayedEnd = [];
		
		polyphony = 0;
		activeTones = new Map<Int, ToneData>();
		toneReleased = new Signal<Int->Void>();
		toneBegin = new Signal<Int->Int->Void>();
		toneEnd = new Signal<Int->Int->Void>();
		// Hmm - Firefox (dev) appears to need the setTargetAtTime time to be a bit in the future for it to work in the release phase.
		// (apparently about 4096 samples worth of data (1 buffer perhaps?))
		// If I use context.currentTime the setTargetAtTime will not fade-out, it just ends aruptly.  
		// Even with this delay in place it's still occasionaly glitchy...
		// Works fine in Chrome
		releaseFudge = isFirefox() ? (4096 / context.sampleRate) : 0;
		
		// set some reasonable defaults
		type 	= OscillatorType.SINE;
		attack 	= .001;
		release = .25;
		volume 	= .1;
		
		#if debug
		toneBegin.connect(function(id, poly) {
			trace('toneBegin | id:$id, polyphony:$poly, time:${now()}');
		});		
		toneReleased.connect(function(id) {
			trace('toneReleased | id:$id, time:${now()}');
		});
		toneEnd.connect(function(id, poly) {
			trace('toneEnd | id:$id, polyphony:$poly, time:${now()}');
		});
		#end
		
		tick(.0);
	}
	
	
	/**
	 * Play a frequency
	 * tones.playFrequency(440); // plays a 440 Hz tone
	 * tones.playFrequency(440, 1); // plays a 440 Hz tone, in one second
	 * tones.playFrequency(440, 1, false); // plays a 440 Hz tone, in one second, and doesn't release untill you call doRelease(toneId)
	 *
	 * @param	freq		- A frequency, expressed in Hertz, and above zero. Typically in the audible range 20Hz-20KHz
	 * @param	delayBy		- A time, in seconds, to delay triggering this tone by.
	 * @param	autoRelease - Release as soon as attack phase ends - default behaviour (true)
	 * 						  when false the tone will play until doRelease(toneId) is called
	 * 						- Don't use these behaviours at the same time in one Tones instance 
	 * @return 	toneId		- The ID assigned to the tone being played. Use for doRelease() when using autoRelease=false
	 */
    public function playFrequency(freq:Float, delayBy:Float = .0, autoRelease:Bool = true):Int {
	   
		var id = ID; ID++;
		
		var envelope = context.createGain();
		var triggerTime = now() + delayBy;
		var releaseTime = triggerTime + attack;
		
		envelope.gain.value = 0;
		envelope.connect(destination);
		
		// attack
		envelope.gain.setTargetAtTime(volume, triggerTime, getTimeConstant(attack));
		
		var osc = context.createOscillator();
		if (type == OscillatorType.CUSTOM) osc.setPeriodicWave(customWave);
		else osc.type = cast type; // firefox throws InvalidStateError if setting osc type and using setPeriodicWave
		
		// set freq value before connecting
		osc.frequency.value = freq;
		
		osc.connect(envelope);
		osc.start(triggerTime);
		
		activeTones.set(id, { id:id, osc:osc, env:envelope, attack:attack, release:release, triggerTime:triggerTime } );
		
		
		// The tone won't actually begin now if there's a delay set... 
		// if only there were a way to get a callback or event to fire at a specific audio conext time...
		if (delayBy == 0) triggerToneBegin(id);
		else delayedBegin.push( { id:id, time:triggerTime } );		
		if (autoRelease) doRelease(id, releaseTime);
		
		return id;
	}
	
	/**
	 * 
	 * @param	id - tone id
	 * @param	delay - in seconds, relative to the current context time
	 */
	public function releaseAfter(id:Int, delay:Float) {
		doRelease(id, now() + delay);
	}
	
	
	/**
	 * 
	 * @param	id - tone id
	 * @param	atTime - the context time to release at. Don't pass anything and release begins immediately.
	 */
	public function doRelease(id:Int, atTime:Float=-1) {
		var data = getToneData(id);
		if (data == null) return;
		
		var time;
		var nowTime = now();
		
		if (atTime < nowTime) time = nowTime;
		else time = atTime;
		
		time += releaseFudge;
		var dt = time - nowTime;
		
		if (dt > 0) delayedRelease.push( { id:id, time:time } );
		else toneReleased.emit(id);
		
		data.env.gain.cancelScheduledValues(time);
		data.env.gain.setTargetAtTime(0, time, getTimeConstant(data.release));
		delayedEnd.push( { id:id, time:time + data.release } );
	}
	
	
	public function releaseAll(atTime:Float = -1) {
		for (id in activeTones.keys()) doRelease(id, atTime);
	}
	
	
	public function stopAll() {
		for (id in activeTones.keys()) doStop(id);
	}
	
    
	/**
	 * Stop and disconnect nodes after release completes
	 * @param	id
	 */
	public function doStop(id:Int) {
		var data = activeTones.get(id);
		if (data == null) return;
		
		data.osc.stop(now());
		data.osc.disconnect();
		
		data.env.gain.cancelScheduledValues(now());
		data.env.disconnect();
		
		triggerToneEnd(id);
		
		activeTones.remove(id);
	}
	
	
	/**
	 * Gets the ToneData for an active tone (osc,env,settings,etc)
	 * @param	id
	 * @return	ToneData
	 */
	inline public function getToneData(id:Int):ToneData return activeTones.get(id);
	
	
	/**
	 * The current audio-context time
	 * @return
	 */
	inline public function now():Float return context.currentTime;
	
	
	// get / set
	
	inline function get_attack():Float return _attack;
	function set_attack(value:Float):Float {
		if (value < 0.001) value = 0.001;
		return _attack = value;
	}
	
	inline function get_release():Float return _release;
	function set_release(value:Float):Float {
		if (value < 0.001) value = 0.001;
		return _release = value;
	}
	
	inline function get_volume():Float return _volume;
	function set_volume(value:Float):Float {
		if (value < 0) value = 0;
		else if (value > 1) value = 1;
		return _volume = value;
	}
	
	
	// internal
	function triggerToneBegin(id:Int):Void {
		polyphony++;
		toneBegin.emit(id, polyphony);
	}
	
	function triggerToneEnd(id:Int):Void {
		polyphony--;
		toneEnd.emit(id, polyphony);
	}
	
	
	var lastTime:Float = .0;
	function tick(_) {
		
		// regularly check for delayed starts, releases, and stops 
		// in a requestAnimationFrame callback instead of creating
		// lots of anonymous Timer.delay callbacks
		// no function allocations, just array modification
		// could optimise further if there was a maximum polyphony limit...
		
		Browser.window.requestAnimationFrame(tick);
		
		var t = now();
		var dt = (t - lastTime) / 2;
		lastTime = t;
		
		var j = 0;
		var n = delayedBegin.length;
		while (j < n) {
			var item = delayedBegin[j];
			if (t+dt > item.time) {
				triggerToneBegin(item.id);
				delayedBegin.splice(j, 1);
				n--;
			} else {
				j++;
			}
		}
		
		j = 0;
		n = delayedRelease.length;
		while (j < n) {
			var item = delayedRelease[j];
			if (t +dt> item.time) {
				toneReleased.emit(item.id);
				delayedRelease.splice(j, 1);
				n--;
			} else {
				j++;
			}
		}
		
		j = 0;
		n = delayedEnd.length;
		while (j < n) {
			var item = delayedEnd[j];
			if (t + dt > item.time) {
				doStop(item.id);
				delayedEnd.splice(j, 1);
				n--;
			} else {
				j++;
			}
		}
	}
}