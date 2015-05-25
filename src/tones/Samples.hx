package tones;

import haxe.Timer;
import hxsignal.Signal;
import js.Browser;
import js.html.audio.AudioBuffer;

import js.html.audio.AudioContext;
import js.html.audio.AudioNode;
import js.html.audio.GainNode;

/**
 * ...
 * @author bit101 - https://github.com/bit101/tones
 * @author Mike Almond - https://github.com/mikedotalmond
 */

class Samples {
  
	static public inline var TimeConstDivider = 4.605170185988092; // Math.log(100);
	static public inline function getTimeConstant(time:Float) return Math.log(time + 1.0) / TimeConstDivider;
	
	static inline function isFirefox() return Browser.navigator.userAgent.indexOf('Firefox') > -1;
	
	public static function createContext():AudioContext {
		return untyped __js__('new (window.AudioContext || window.webkitAudioContext)()');
	}
	
	
	public var context(default, null):AudioContext;
	public var destination(default, null):AudioNode;
	
	public var buffer:AudioBuffer = null;
	
	public var attack	(get, set):Float; // seconds
	public var release	(get, set):Float; // seconds
	public var volume	(get, set):Float;
	public var playbackRate:Float;
	
	public var lastId		(default, null):Int;
	public var polyphony	(default, null):Int;
	public var activeSamples(default, null):Map<Int, SampleData>;
	public var sampleBegin	(default, null):Signal<Int->Float->Void>;
	public var sampleRelease(default, null):Signal<Int->Float->Void>;
	public var sampleEnd	(default, null):Signal<Int->Void>;
	
	var ID:Int = 0;
	var _attack:Float;
	var _release:Float;
	var _volume:Float;
	var releaseFudge:Float;
	var lastTime:Float = .0;
	
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
		
		lastId = ID;
		polyphony = 0;
		activeSamples = new Map<Int, SampleData>();
		sampleRelease = new Signal<Int->Float->Void>();
		sampleBegin = new Signal<Int->Float->Void>();
		sampleEnd = new Signal<Int->Void>();
		// Hmm - Firefox (dev) appears to need the setTargetAtTime time to be a bit in the future for it to work in the release phase.
		// (apparently about 4096 samples worth of data (1 buffer perhaps?))
		// If I use context.currentTime the setTargetAtTime will not fade-out, it just ends aruptly.  
		// Even with this delay in place it's still occasionaly glitchy...
		// Works fine in Chrome
		releaseFudge = isFirefox() ? (4096 / context.sampleRate) : 0;
		
		// set some reasonable defaults
		attack 	= 0.0;
		release = 1.0;
		volume 	= .2;
		playbackRate = 1.0;
		
		#if debug
		sampleBegin.connect(function(id, time) {
			trace('sampleBegin | id:$id, time:$time');
		});		
		sampleRelease.connect(function(id, time) {
			trace('sampleRelease | id:$id, time:$time');
		});
		sampleEnd.connect(function(id) {
			trace('sampleEnd | id:$id, time:${now()}');
		});
		#end
		
		tick(.0);
	}
	
	
	/**
	 * Play a sample
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
    public function playSample(buffer:AudioBuffer, delayBy:Float = .0, autoRelease:Bool = true):Int {
	   
		var id = ID; ID++;
		lastId = id;
		
		var envelope = context.createGain();
		var triggerTime = now() + delayBy;
		var releaseTime = triggerTime + attack;
		
		envelope.gain.value = 0;
		envelope.connect(destination);
		// attack
		envelope.gain.setTargetAtTime(volume, triggerTime, getTimeConstant(attack));
		
		var src = context.createBufferSource();
		src.buffer = buffer;
		src.playbackRate.value = playbackRate;
		
		src.connect(envelope);
		src.start(triggerTime);
		
		activeSamples.set(id, { id:id, src:src, env:envelope, attack:attack, release:release, triggerTime:triggerTime } );
		
		if (delayBy == .0) triggerSampleBegin(id, triggerTime);
		else delayedBegin.push({id:id, time:triggerTime});
		
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
		var data = getSampleData(id);
		if (data == null) return;
		
		var time;
		var nowTime = now();
		
		if (atTime < nowTime) time = nowTime;
		else time = atTime;
		
		time += releaseFudge;
		var dt = time - nowTime;
		
		if (dt > 0) delayedRelease.push( { id:id, time:time } );
		else sampleRelease.emit(id, nowTime);
		
		data.env.gain.cancelScheduledValues(time);
		data.env.gain.setTargetAtTime(0, time, getTimeConstant(release));
		delayedEnd.push( { id:id, time:time + release } );
	}
	
	
	public function releaseAll(atTime:Float = -1) {
		for (id in activeSamples.keys()) doRelease(id, atTime);
	}
	
	
	public function stopAll() {
		for (id in activeSamples.keys()) doStop(id);
	}
	
    
	/**
	 * Stop and disconnect nodes after release completes
	 * @param	id
	 */
	public function doStop(id:Int) {
		var data = activeSamples.get(id);
		if (data == null) return;
		
		data.src.stop(now());
		data.src.disconnect();
		
		data.env.gain.cancelScheduledValues(now());
		data.env.disconnect();
		
		triggerSampleEnd(id);
		
		activeSamples.remove(id);
	}
	
	
	/**
	 * Gets the SampleData for an active tone (src,env,settings,etc)
	 * @param	id
	 * @return	SampleData
	 */
	inline public function getSampleData(id:Int):SampleData return activeSamples.get(id);
	
	
	/**
	 * The current audio-context time
	 * @return
	 */
	inline public function now():Float return context.currentTime;
	
	
	// get / set
	
	inline function get_attack():Float return _attack;
	function set_attack(value:Float):Float {
		if (value < 0.0001) value = 0.0001;
		return _attack = value;
	}
	
	inline function get_release():Float return _release;
	function set_release(value:Float):Float {
		if (value < 0.0001) value = 0.0001;
		return _release = value;
	}
	
	inline function get_volume():Float return _volume;
	function set_volume(value:Float):Float {
		if (value < 0) value = 0;
		else if (value > 1) value = 1;
		return _volume = value;
	}
	
	
	// internal
	function triggerSampleBegin(id:Int, time:Float):Void {
		polyphony++;
		sampleBegin.emit(id, time);
	}
	
	function triggerSampleEnd(id:Int):Void {
		polyphony--;
		sampleEnd.emit(id);
	}
	
	
	function tick(_) {
		
		// regularly check for delayed starts, releases, and stops 
		// in a requestAnimationFrame callback instead of creating
		// lots of anonymous Timer.delay callbacks
		// no function allocations, just array modification
		// could optimise further if there was a maximum polyphony limit...
		
		Browser.window.requestAnimationFrame(tick);
		
		var t = now();
		var dt = t - lastTime;
		lastTime = t;
		
		var nextTime = t + dt*2;
		// Estimated 'next+1' frame-time
		// If an audio event is going to happen between frames, then we want to make sure the signal is triggered beforehand.
		// Passing the actual audio context time of the event in the signal being triggered should allow for accurate sync. 
		
		var j = 0;
		var n = delayedBegin.length;
		while (j < n) {
			var item = delayedBegin[j];
			if (nextTime > item.time) {
				triggerSampleBegin(item.id, item.time);
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
			if (nextTime > item.time) {
				sampleRelease.emit(item.id, item.time);
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
			if (t >= item.time) {
				doStop(item.id);
				delayedEnd.splice(j, 1);
				n--;
			} else {
				j++;
			}
		}
	}
}