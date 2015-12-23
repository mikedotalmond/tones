package tones.data;

@:native("window.TonesOscillatorTypeShim")
extern enum OscillatorType {
	SINE; SQUARE; TRIANGLE; SAWTOOTH; CUSTOM;
}

@:keep @:noCompletion @:final class OscillatorTypeShim {	
	static function __init__() {
		var node:Dynamic = untyped __js__('window.OscillatorNode');
		if (node != null) {
			if (Reflect.hasField(node, "SINE")) {
				// older chrome / webkit
				untyped __js__('window.TonesOscillatorTypeShim = {SINE:node.SINE, SQUARE:node.SQUARE, TRIANGLE:node.TRIANGLE, SAWTOOTH:node.SAWTOOTH, CUSTOM:node.CUSTOM}');
			} else {
				untyped __js__('window.TonesOscillatorTypeShim = {SINE:"sine", SQUARE:"square", TRIANGLE:"triangle", SAWTOOTH:"sawtooth", CUSTOM:"custom"}');
			}
		}
	}
}