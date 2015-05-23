package tones.examples;

import js.html.audio.AudioBuffer;
import js.html.XMLHttpRequestResponseType;

import tones.Samples;
import tones.utils.NoteFrequencyUtil;
import tones.utils.TimeUtil;

import js.html.XMLHttpRequest;
/**
 * ...
 * @author Mike Almond - https://github.com/mikedotalmond
 */
class SamplesBasic {

	
	var samples:Samples;
	var restartId:Int;
	var buffer:AudioBuffer;
	
	public function new() {
		
		samples = new Samples();
		samples.sampleBegin.connect(onSampleBegin);
		
		var request = new XMLHttpRequest();
		request.open("GET", 'data/samples/kick.wav', true);
		request.responseType = XMLHttpRequestResponseType.ARRAYBUFFER;
		request.onload = function(_) samples.context.decodeAudioData(_.currentTarget.response, sampleDecoded);
		request.send();
		
	}	
	
	function sampleDecoded(buffer:AudioBuffer) {
		this.buffer = buffer;
		
		samples.attack = 0;
		
		// play it pitched up a bit (5 tones)
		var rate = NoteFrequencyUtil.rateFromNote(5, 0, 0);
		
		samples.release = buffer.duration / rate;
		samples.playbackRate = rate;
		
		restartId = samples.lastId;
		samples.playSample(buffer, .5); 
	}
	
	function onSampleBegin(id:Int, poly:Int) {
		if (id == restartId) {
			playSequence();
		}
	}
	
	function playSequence() {
		samples.playSample(buffer, TimeUtil.stepTime(1)); 
		samples.playSample(buffer, TimeUtil.stepTime(2)); 
		samples.playSample(buffer, TimeUtil.stepTime(3)); 
		samples.playSample(buffer, TimeUtil.stepTime(4)); 
		samples.playSample(buffer, TimeUtil.stepTime(5)); 
		samples.playSample(buffer, TimeUtil.stepTime(6)); 
		samples.playSample(buffer, TimeUtil.stepTime(6.25)); 
		samples.playSample(buffer, TimeUtil.stepTime(6.5)); 
		samples.playSample(buffer, TimeUtil.stepTime(6.75)); 
		samples.playSample(buffer, TimeUtil.stepTime(7)); 
		samples.playSample(buffer, TimeUtil.stepTime(7.25)); 
		samples.playSample(buffer, TimeUtil.stepTime(7.5)); 
		samples.playSample(buffer, TimeUtil.stepTime(7.75));
		restartId = samples.playSample(buffer, TimeUtil.stepTime(8));
	}
}