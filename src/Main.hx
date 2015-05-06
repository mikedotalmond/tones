package;

import tones.examples.*;

/**
 * ...
 * @author Mike Almond - https://github.com/mikedotalmond
 */
class Main {
	
	static function main() {
		
		/** The simplest usage **/
		//var basic = new Basic();
		
		/** Play and hold a tone, then release it later **/
		//var releaseLater = new ReleaseLater();
		
		/** Sharing, or using a shnared, AudioContext **/
		//var sharedContext = new SharedContext();
		
		/** **/
		//var customWaves	= new CustomWaves();
		
		/** Something a bit more complete that combines stuff seen in the earlier examples **/
		var polysynth = new KeyboardControlled();
	}
}