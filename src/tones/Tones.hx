package tones;

import js.html.audio.AudioContext;
import js.html.audio.AudioNode;

import tones.data.OscillatorType;
import tones.utils.TimeUtil;

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

class Tones extends AudioBase {

	public var type			:OscillatorType;
	public var customWave	:PeriodicWave = null;

	/**
	 * @param	audioContext 	- optional. Pass an exsiting audioContext here to share it.
	 * @param	destinationNode - optional. Pass a custom destination AudioNode to connect to.
	 */
	public function new(audioContext:AudioContext = null, ?destinationNode:AudioNode = null) {
		super(audioContext, destinationNode);
		type = OscillatorType.SINE;
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
		var osc = context.createOscillator();
		if (type == OscillatorType.CUSTOM) osc.setPeriodicWave(customWave);
		else osc.type = cast type;
		
		osc.frequency.value = freq;
		osc.connect(envelope);
		osc.start(triggerTime + sampleTime);
		
		//
		//
		activeItems.set(id, { id:id, src:osc, env:envelope, volume:volume, attack:attack, release:release, triggerTime:triggerTime } );
		
		if (delayBy < sampleTime) triggerItemBegin(id, triggerTime);
		else delayedBegin.push({id:id, time:triggerTime});
		
		if (autoRelease) doRelease(id, releaseTime + sampleTime);
		
		return id;
	}
}