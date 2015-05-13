package tones.examples;
import tones.utils.NoteFrequencyUtil;

/**
 * ...
 * @author Mike Almond - https://github.com/mikedotalmond
 */
class Sequence {
	
	var tones:Tones;

	public function new() {
		
		tones 			= new Tones();
		tones.volume 	= .1;
		tones.attack 	= 25;
		tones.release 	= 1000;
		tones.type		= OscillatorType.SAWTOOTH;
		
		var freqUtil = new NoteFrequencyUtil();
		
		// simplest case - use delays to sequence		
		tones.playFrequency(freqUtil.noteNameToFrequency('C3'), 0);
		tones.playFrequency(freqUtil.noteNameToFrequency('C4'), .2);
		tones.playFrequency(freqUtil.noteNameToFrequency('C5'), .4);
		
		tones.playFrequency(freqUtil.noteNameToFrequency('G3'), .8);
		tones.playFrequency(freqUtil.noteNameToFrequency('G4'), 1);
		tones.playFrequency(freqUtil.noteNameToFrequency('G5'), 1.2);
		
		tones.playFrequency(freqUtil.noteNameToFrequency('G2'), 1);
		tones.playFrequency(freqUtil.noteNameToFrequency('G1'), 1.2);
		
		
	}
}