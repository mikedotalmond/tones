package tones.examples;
import tones.utils.NoteFrequencyUtil;

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
		tones.attack 	= 25;
		tones.release 	= 1000;
		tones.type		= OscillatorType.SAWTOOTH;
		
		freqUtil = new NoteFrequencyUtil();
		lastNoteId = -1;
		
		// simplest case - use delays to sequence	
		tones.toneEnd.connect(function(id, poly) {
			// every now and then, based on the current polyphony, play a random note on the off-beat between the sequenced notes.
			var r = 2 + Std.int(Math.random() * 12);
			if (poly == r) {
				tones.volume = .05;
				var octave = 1 + Std.int(Math.random() * 3);
				var note = NoteFrequencyUtil.pitchNames[Std.int(Math.random() * 12)];
				tones.playFrequency(freqUtil.noteNameToFrequency('$note$octave'), .1);
			}
			
			// could get into some fun sequence generation by using the current polyphony
			// and the id of a tone that ended to decice if a new one should play... 
			// .. if(id%3==0)
		});
		
		tones.toneBegin.connect(function(id, poly) {
			if (id == lastNoteId) { 
				// last note was triggered? 
				// restart the sequence - the last note doubles up with the first in this loop.
				playSequence();
			}
		});
		
		playSequence();
	}
	
	function playSequence() {
			
		tones.volume = .05;
		tones.playFrequency(freqUtil.noteNameToFrequency('C3'), 0);
		tones.playFrequency(freqUtil.noteNameToFrequency('C4'), .2);
		tones.playFrequency(freqUtil.noteNameToFrequency('C5'), .4);
		
		tones.volume *= .9;
		tones.playFrequency(freqUtil.noteNameToFrequency('G3'), .8);
		tones.volume *= .8;
		tones.playFrequency(freqUtil.noteNameToFrequency('G4'), 1);
		tones.volume *= .7;
		tones.playFrequency(freqUtil.noteNameToFrequency('G5'), 1.2);
		
		tones.volume = .08;
		tones.playFrequency(freqUtil.noteNameToFrequency('G2'), 1);
		tones.playFrequency(freqUtil.noteNameToFrequency('G1'), 1.2);
		
		tones.volume = .05;
		lastNoteId = tones.playFrequency(freqUtil.noteNameToFrequency('C1'), 1.4);
	}
}