package tones.examples;
import tones.utils.NoteFrequencyUtil;
import tones.utils.TimeUtil;

import tones.data.OscillatorType;
/**
 * ...
 * @author Mike Almond - https://github.com/mikedotalmond
 */
class Sequence {
	
	var tones:Tones;
	var freqUtil:NoteFrequencyUtil;

	
	var lastNoteId:Int;
	public function new() {
		
		tones			= new Tones();
		tones.volume 	= .1;
		tones.attack 	= .025;
		tones.release 	= 1;
		tones.type		= OscillatorType.SAWTOOTH;
		
		freqUtil = new NoteFrequencyUtil();
		lastNoteId = -1;
		
		tones.itemBegin.connect(function(id, time) {
			
			// time is the audioContext time that this tone starts at 
			// - can/will be a little bit in the future,
			// use it to get a accurate sync 
			
			if (id == lastNoteId) { 
				trace('repeat');
				// last note was triggered - restart the sequence.
				// the last note doubles up with the first in this loop.
				playSequence(time);
			} else {
				// intersperse the repeating pattern with some random off-beat notes
				var r = 2 + Std.int(Math.random() * 10);
				if (tones.polyphony == r) {
					tones.volume = .05;
					var octave = 1 + Std.int(Math.random() * 3);
					var note = NoteFrequencyUtil.pitchNames[Std.int(Math.random() * 12)];
					tones.playFrequency(freqUtil.noteNameToFrequency('$note$octave'), time-tones.now + TimeUtil.stepTime(.25));
				}
			}
		});
		
		playSequence(tones.now);
	}
	
	
	function playSequence(time:Float) {
		
		var start =	time - tones.now;
		
		tones.volume = .05;
		tones.playFrequency(freqUtil.noteNameToFrequency('C3'), start);
		tones.playFrequency(freqUtil.noteNameToFrequency('C4'), start + TimeUtil.stepTime(.5));
		tones.playFrequency(freqUtil.noteNameToFrequency('C5'), start + TimeUtil.stepTime(1));
		
		tones.playFrequency(freqUtil.noteNameToFrequency('G3'), start + TimeUtil.stepTime(2));
		tones.playFrequency(freqUtil.noteNameToFrequency('G4'), start + TimeUtil.stepTime(2.5));
		tones.playFrequency(freqUtil.noteNameToFrequency('G5'), start + TimeUtil.stepTime(3));
		
		// loop point..
		tones.playFrequency(freqUtil.noteNameToFrequency('G2'), start + TimeUtil.stepTime(4));
		lastNoteId = tones.playFrequency(freqUtil.noteNameToFrequency('C2'), start + TimeUtil.stepTime(4));
	}
}