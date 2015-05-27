package tones.examples;

import js.html.audio.OscillatorNode;
import tones.data.ItemData;
import tones.Tones;
import tones.utils.TimeUtil;
import tones.data.OscillatorType;

/**
 * ...
 * @author Mike Almond - https://github.com/mikedotalmond
 */
class FreqSlide {
	
	var tones:Tones;

	public function new() {
		
		tones = new Tones(); // create 
		
		tones.itemBegin.connect(onToneStart);
		tones.itemRelease.connect(onToneReleased);
		
		// change some settings...
		tones.type = OscillatorType.SQUARE;
		tones.volume = .04;
		tones.attack = .200;
		tones.release = .400;
		
		tones.playFrequency(220, .5, false);
	}
	
	function onToneStart(id, time) {
		var data = tones.getItemData(id);
		// a note started...
		// slide to a value in the range of 20-440Hz, over ~1 second
		cast(data.src, OscillatorNode).frequency.setTargetAtTime(20 + 420 * Math.random(), tones.context.currentTime, TimeUtil.getTimeConstant(1));
		tones.releaseAfter(id, 1); // release after 1 second
	}
	
	function onToneReleased(id, time) {
		var data = tones.getItemData(id);
		// a note was released, play another, starting at the frequency of the last note...
		tones.playFrequency(cast(data.src, OscillatorNode).frequency.value , 0, false);
	}
}