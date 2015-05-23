package tones.utils;

/**
 * ...
 * @author Mike Almond - https://github.com/mikedotalmond
 */
class TimeUtil {

	public inline static function stepTime(beats:Float, bpm:Float = 120):Float {
		return beats / (bpm / 60);
	}
	
}