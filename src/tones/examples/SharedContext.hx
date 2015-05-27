package tones.examples;

import js.html.audio.PanningModelType;
import tones.Tones;
import tones.data.OscillatorType;

import js.html.audio.PannerNode;
import js.html.audio.AudioContext;

/**
 * ...
 * @author Mike Almond - https://github.com/mikedotalmond
 */
class SharedContext {

	var context:AudioContext;

	public function new() {
		
		context = AudioBase.createContext();
		
		var pan1 = context.createPanner();
		var pan2 = context.createPanner();
		pan1.panningModel = PanningModelType.EQUALPOWER;// 'equalpower';
		pan2.panningModel = PanningModelType.EQUALPOWER;// 'equalpower';
		
		setPan(.5, pan1);	
		setPan( -.5, pan2);	
		
		var masterVolume = context.createGain(); // create a gain node to act as master volume
		masterVolume.gain.value = .5;
		masterVolume.connect(context.destination); // connect the volume control to the context's destintion
		
		pan1.connect(masterVolume);
		pan2.connect(masterVolume);
		
		var tones1 = new Tones(context, pan1); // pan right by .5
		var tones2 = new Tones(context, pan2); // pan left by .5
		
		// change some settings...
		tones1.type = OscillatorType.SAWTOOTH;
		tones1.volume = .2;
		tones1.attack = .001;
		tones1.release = 2.500;
		
		// change some settings...
		tones2.type = OscillatorType.SQUARE;
		tones2.volume = .2;
		tones2.attack = .500;
		tones2.release = 1.500;
		
		// wait .1 seconds, then play a note...
		tones1.playFrequency(220, .5);
		// wait .2 seconds, then play a note...
		tones2.playFrequency(110, 1);
		
	}
	
	function setPan(value:Float=0, node:PannerNode):Void {
		var x = value * Math.PI /2;
		var z = x + Math.PI / 2;
		if (z > Math.PI / 2) z = Math.PI - z;
		node.setPosition(Math.sin(x), 0, Math.sin(z));
	}
}