package tones.data;

/**
 * @author Mike Almond - https://github.com/mikedotalmond
 */

import js.html.audio.GainNode;

import js.html.audio.AudioNode;
import js.html.audio.OscillatorNode;
import js.html.audio.AudioBufferSourceNode;

typedef ItemSrcNode = haxe.extern.EitherType<AudioBufferSourceNode, OscillatorNode>;

typedef ItemData = {
	var id:Int;
	var src:ItemSrcNode;
	var env:GainNode;
	var triggerTime:Float;
	var attack:Float;
	var release:Float;
	var volume:Float;
}