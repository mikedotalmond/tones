package tones;

import hxsignal.Signal;
import js.html.audio.AudioBuffer;
import js.html.audio.AudioContext;
import js.html.audio.AudioNode;
import tones.data.ItemData;
import tones.utils.TimeUtil;


/**
 * ...
 * @author bit101 - https://github.com/bit101/tones
 * @author Mike Almond - https://github.com/mikedotalmond
 */

class Samples extends AudioBase {

	public var buffer(get, set):AudioBuffer;
	public var playbackRate:Float;
	public var offset:Float;
	public var duration:Float;

	var _buffer:AudioBuffer = null;
	inline function get_buffer() return _buffer;
	function set_buffer(value:AudioBuffer):AudioBuffer {
		offset = 0;
		duration = value.duration;
		return _buffer = value;
	}


	/**
	 * @param	audioContext 	- optional. Pass an exsiting audioContext here to share it.
	 * @param	destinationNode - optional. Pass a custom destination AudioNode to connect to.
	 */
	public function new(audioContext:AudioContext = null, ?destinationNode:AudioNode = null) {
		super(audioContext, destinationNode);
		playbackRate = 1.0;
		offset = 0;
		duration = 0;
	}


	/**
	 * Play a sample
	 * sample.playSample(myBuffer); // play the myBuffer sample
	 * sample.playSample(myBuffer, 1); // play the myBuffer sample, in one second
	 * sample.playSample(myBuffer, 1, false); // play the myBuffer sample, in one second, and doesn't release untill you call doRelease(toneId)
	 *
	 * @param	buffer		- The AudioBuffer to play from
	 * @param	delayBy		- A time, in seconds, to delay triggering this sample by.
	 * @param	autoRelease - Release as soon as attack phase ends - default behaviour (true)
	 * 						  when false the sample will play until doRelease(sampleId) is called
	 * 						- Don't use these behaviours at the same time in one Samples instance
	 * @return 	id			- The ID assigned to the tone being played. Use for doRelease() when using autoRelease=false
	 */
    public function playSample(buffer:AudioBuffer, delayBy:Float = .0, autoRelease:Bool = true):Int {

		if (buffer != null) this.buffer = buffer;
		if (delayBy < 0) delayBy = 0;
		
		var id = nextID();
		var triggerTime = now + delayBy;
		var releaseTime = triggerTime + attack;
		var envelope = context.createGain();
		
		//
		//
		envelope.gain.value = 0;
		envelope.gain.setValueAtTime(0, triggerTime); // start at zero
		envelope.gain.linearRampToValueAtTime(volume, releaseTime); // ramp up to volume during attack
		envelope.gain.setValueAtTime(volume, releaseTime); // set at volume after ramp
		envelope.connect(destination);
		
		//
		//
		var src = context.createBufferSource();
		src.buffer = this.buffer;
		src.playbackRate.value = playbackRate;
		
		src.connect(envelope);
		if (duration <= 0) duration = buffer.duration;
		src.start(triggerTime, offset, duration);
		
		//
		//
		activeItems.set(id, { id:id, src:src, volume:volume, env:envelope, attack:attack, release:release, triggerTime:triggerTime } );

		if (delayBy < sampleTime) triggerItemBegin(id, triggerTime);
		else delayedBegin.push({id:id, time:triggerTime});
		
		if (autoRelease) doRelease(id, releaseTime + sampleTime);

		return id;
	}
}