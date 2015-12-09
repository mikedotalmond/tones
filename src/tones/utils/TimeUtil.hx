package tones.utils;
import hxsignal.Signal;
import js.Browser;

/**
 * ...
 * @author Mike Almond - https://github.com/mikedotalmond
 */
class TimeUtil {
	
	static var initTime:Float = 0;
	static var nowTime:Void->Float = null;
	static var _frameTick:Signal<Float->Void> = null;
	
	static public inline var TimeConstDivider = 4.605170185988092; // Math.log(100);
	static public inline function getTimeConstant(time:Float) return Math.log(time + 1.0) / TimeConstDivider;
	public inline static function stepTime(beats:Float, bpm:Float = 120):Float return beats / (bpm / 60);

	/**
	 * millis since application started
	 * Uses window.performance.now where avilable.
	 * @return
	 */
	public static var now(get, never):Float;	
	inline static function get_now() return nowTime();
	
	/**
	 * requestAnimationFrame signal
	 */
	static public var frameTick(get, never):Signal<Float->Void>;
	inline static function get_frameTick() return _frameTick;
	
	//
	
	static function onFrame(_) {
		frameTick.emit(_);
		Browser.window.requestAnimationFrame(onFrame);
	}
	

	static function __init__() {
		_frameTick = new Signal<Float->Void>();
		Browser.window.requestAnimationFrame(onFrame);
		
		if (Reflect.hasField(Browser.window, 'performance') && Reflect.isFunction(Browser.window.performance.now)) {
			nowTime = Browser.window.performance.now;
		} else {
			initTime = Date.now().getTime();
			nowTime = function() return Date.now().getTime() - initTime;
		}
	}
}