package tones;

/**
 * @author Mike Almond - https://github.com/mikedotalmond
 */

import js.html.audio.AudioBufferSourceNode;
import js.html.audio.GainNode;

typedef SampleData = {
	var id:Int;
	var src:AudioBufferSourceNode;
	var env:GainNode;
	var triggerTime:Float;
	var attack:Float;
	var release:Float;	
}