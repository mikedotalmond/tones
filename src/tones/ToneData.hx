package tones;

/**
 * @author Mike Almond - https://github.com/mikedotalmond
 */

import js.html.audio.GainNode;
import js.html.audio.OscillatorNode;

typedef ToneData = {
	var id:Int;
	var osc:OscillatorNode;
	var env:GainNode;
	var triggerTime:Float;
	var attack:Float;
	var release:Float;	
}