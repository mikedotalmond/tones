package tones.examples;

import tones.Tones;

import js.html.audio.AudioContext;

/**
 * ...
 * @author Mike Almond - https://github.com/mikedotalmond
 */
class SharedContext {

	var context:AudioContext;

	public function new() {
		
		context = Tones.createContext();
		
		var masterVolume = context.createGain(); // create a gain node to act as master volume
		masterVolume.gain.value = .5;
		masterVolume.connect(context.destination); // connect the volume control to the context's destintion
		
		var tones1 = new Tones(context, masterVolume);
		var tones2 = new Tones(context, masterVolume);
		
	}
}