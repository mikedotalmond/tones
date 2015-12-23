package tones.data;
import js.Browser;

@:native("window.TonesFilterTypeShim")
extern enum FilterType {
	ALLPASS; BANDPASS; HIGHPASS; HIGHSHELF; LOWPASS; LOWSHELF; NOTCH; PEAKING;
}

@:keep @:noCompletion @:final class FilterTypeShim {
	static function __init__() {
		// fix some differences in api implementation between chrome/firefox
		var Node = Reflect.getProperty(Browser.window, "BiquadFilterNode");
		if (Node != null) {
			if (Reflect.hasField(Node, "LOWPASS")) {
				untyped __js__('window.TonesFilterTypeShim = {ALLPASS:Node.ALLPASS, BANDPASS:Node.BANDPASS, HIGHPASS:Node.HIGHPASS, HIGHSHELF:Node.HIGHSHELF, LOWPASS:Node.LOWPASS, LOWSHELF:Node.LOWSHELF, NOTCH:Node.NOTCH, PEAKING:Node.PEAKING}');
			} else {
				untyped __js__('window.TonesFilterTypeShim = {ALLPASS:"allpass", BANDPASS:"bandpass", HIGHPASS:"highpass", HIGHSHELF:"highshelf", LOWPASS:"lowpass", LOWSHELF:"lowshelf", NOTCH:"notch", PEAKING:"peaking"}');
			}
		}
	}
}
