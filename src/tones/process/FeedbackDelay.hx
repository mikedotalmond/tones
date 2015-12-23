package tones.process;

import js.html.audio.AudioContext;
import js.html.audio.AudioNode;
import js.html.audio.AudioParam;
import js.html.audio.BiquadFilterNode;
import js.html.audio.DelayNode;
import js.html.audio.GainNode;

import tones.data.FilterType;

class FeedbackDelay {
	
	var _level	:GainNode;
	var _delay	:DelayNode;
	var _feedback:GainNode;
	var _biquad	:BiquadFilterNode;
	
	/**
	 * Delay time, seconds
	 */
	public var time(get, never):AudioParam;
	/**
	 * Delay (wet) mix level
	 */
	public var level(get, never):AudioParam;
	/**
	 * Delay feedback amount
	 */
	public var feedback(get, never):AudioParam;	
	
	/**
	 * filter freq
	 */
	public var filterFrequency(get, never):AudioParam;
	/**
	 * filter freq detune (cents)
	 */
	public var filterDetune(get, never):AudioParam;
	/**
	 * filter q
	 */
	public var filterQ(get, never):AudioParam;
	/**
	 * filter gain (for shelf/peak)
	 * @see https://developer.mozilla.org/en-US/docs/Web/API/BiquadFilterNode for more info
	 */
	public var filterGain(get, never):AudioParam;
	
	
	/**
	 *  1st node in chain (connect input here)
	 */ 
	public var input(get, never):AudioNode; 
	
	
	/**
	 *  last node in chain (read output from here)
	 */ 
	public var output(get, never):AudioNode;
	
	
	/**
	 * 
	 * @param	context
	 * @param	maxDelay
	 */
	public function new(context:AudioContext, maxDelay:Float=1.0, ?filterType:FilterType = null) {
		
		_level = context.createGain();
		_feedback = context.createGain();
		_delay = context.createDelay(maxDelay);
		
		_level.gain.setValueAtTime(.25, 0);
		_feedback.gain.setValueAtTime(.5, 0);
		
		_biquad = context.createBiquadFilter();
		_biquad.type = filterType == null ? cast FilterType.LOWPASS : cast filterType;
		
		_level.connect(_delay);
		
		_delay.connect(_biquad);
		_biquad.connect(_feedback);
		
		_feedback.connect(_delay);
	}
	
	inline function get_time():AudioParam return _delay.delayTime; 
	inline function get_level():AudioParam return _level.gain; 
	inline function get_feedback():AudioParam return _feedback.gain; 
	
	inline function get_filter():BiquadFilterNode return _biquad; 
	inline function get_filterQ():AudioParam return _biquad.Q; 
	inline function get_filterFrequency():AudioParam return _biquad.frequency; 
	inline function get_filterDetune():AudioParam return _biquad.detune; 
	inline function get_filterGain():AudioParam return _biquad.gain; 
	
	inline function get_input():AudioNode return _level; 
	inline function get_output():AudioNode return _delay;
}