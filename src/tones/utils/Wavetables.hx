package tones.utils;

/**
 * ...
 * @author Mike Almond - https://github.com/mikedotalmond
 */

#if !macro
import haxe.Http;
import haxe.Json;
import hxsignal.Signal;
import js.html.Float32Array;

typedef WavetableData = {
	var name:String;
	var real:Float32Array;
	var imag:Float32Array;
}
#end

class Wavetables {
	
	// wavetable was data sourced from chromium.googlecode.com/svn/trunk/samples/audio/wave-tables
	public static var FileNames(default, null):Array<String> = WavetableFiles.processData('src/data/', 'bin/data/wavetables/');
	
#if !macro
	
	public var data(default, null):Array<WavetableData>;
	public var loadComplete(default, null):Signal<Void->Void>;
	
	var errorCount	:Int;
	var successCount:Int;
	
	public function new() {
		loadComplete = new Signal<Void->Void>();
		loadAll();
		// see: stackoverflow.com/questions/20156888/what-are-the-parameters-for-createperiodicwave-in-google-chrome
		// 		www.sitepoint.com/using-fourier-transforms-web-audio-api/
		// 		chromium.googlecode.com/svn/trunk/samples/audio/wave-tables/		
	}
	
	function loadAll() {
		
		data = [];
		successCount = 0;
		errorCount = 0;
		
		for (name in FileNames) {
			var http:Http = new Http('data/wavetables/$name');
			http.onError = onDataError;
			http.onData = onData.bind(_, name);
			http.request();
		}
	}
	
	
	function onData(content:String, name:String) {
		var json = Json.parse(content);
		
		data.push({
			name: name.substring(0, name.length - 5), // strip `.json`
			real: new Float32Array(json.real),
			imag: new Float32Array(json.imag),
		});
		
		successCount++;
		checkComplete();
	}
	
	
	function checkComplete() {
		//trace('successCount:$successCount, errorCount:$errorCount');
		if (errorCount + successCount == FileNames.length) {
			trace('complete - loaded $successCount (${FileNames.length}) wavetables');
			loadComplete.emit();
		}
	}
	
	function onDataError(_) {
		errorCount++;
		checkComplete();
	}
	
#end
}



@:access(CompileTime)
class WavetableFiles {

	/**
	 * Copies files from `fromPath` to `toPath` and returns Array<String> of all the file names
	 * 
	 * @param	fromPath
	 * @param	toPath
	 * @return	filenames
	 */
    macro public static function processData(fromPath:String, toPath:String):ExprOf<{}> {
		
		var names = getFilenames(fromPath);		
		if (names.length > 0) copyFiles(names, fromPath, toPath);
		
        return CompileTime.toExpr(names);
    }	
	
	#if macro
		static function getFilenames(path:String):Array<String> {
			return sys.FileSystem.isDirectory(path) ? sys.FileSystem.readDirectory(path) : [];
		}
		
		static function copyFiles(filenames:Array<String>, from:String, to:String):Void {
			for (name in filenames) sys.io.File.copy(from + name, '$to/$name');
		}
	#end
}
