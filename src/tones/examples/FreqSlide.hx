package tones.examples;

import tones.Tones;

/**
 * ...
 * @author Mike Almond - https://github.com/mikedotalmond
 */
class FreqSlide {
	
	var tones:Tones;

	public function new() {
		
		tones = new Tones(); // create 
		
		tones.toneBegin.connect(onToneStart);
		//tones.toneEnd.connect(onToneEnd);
		tones.toneReleased.connect(onToneReleased);
		
		// change some settings...
		tones.type = OscillatorType.SQUARE;
		tones.volume = .04;
		tones.attack = 200;
		tones.release = 400;
		
		tones.playFrequency(220, .5, false);
	}
	
	function onToneStart(id, poly) {
		var data:ToneData = tones.getToneData(id);
		// a note started...
		// slide to a value in the range of 20-440Hz, over ~1 second
		data.osc.frequency.setTargetAtTime(20 + 420 * Math.random(), tones.context.currentTime, Tones.getTimeConstant(1));
		tones.releaseAfter(id, 1); // release after 1 second
	}
	
	function onToneReleased(id) {
		var data:ToneData = tones.getToneData(id);
		// a note was released, play another, starting at the frequency of the last note...
		tones.playFrequency(data.osc.frequency.value , 0, false);
	}
}