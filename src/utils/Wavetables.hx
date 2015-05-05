package utils;

/**
 * ...
 * @author Mike Almond - https://github.com/mikedotalmond
 */

import haxe.Http;
import haxe.Json;
import hxsignal.Signal;

#if macro
import sys.FileSystem;
import haxe.macro.Context;
import sys.io.File;
#end

typedef WavetableData = {
	var name:String;
	var real:Array<Float>;
	var imag:Array<Float>;
}

class Wavetables {
	
	public static var FileNames	:Array<String> = WavetableFiles.processData('data/');
	
	public var waves(default, null):Array<WavetableData>;
	
	var errorCount	:Int;
	var successCount:Int;
	
	public function new() {
		loadAll();
		// see: stackoverflow.com/questions/20156888/what-are-the-parameters-for-createperiodicwave-in-google-chrome
		// 		www.sitepoint.com/using-fourier-transforms-web-audio-api/
		// 		chromium.googlecode.com/svn/trunk/samples/audio/wave-tables/		
	}
	
	function loadAll() {
		waves = [];
		successCount = 0;
		errorCount = 0;
		promhx.haxe.Http
		for (name in FileNames) {
			var http:Http = new Http('wavetables/$name');
			http.onError = onDataError;
			http.onData = function(_) {
				var data = Json.parse(_);
				data.name = name.substring(0, name.length - 5);
				waves.push(cast data);
				
				successCount++;
				checkComplete();
			};
			http.request();
		}
	}
	
	function checkComplete() {
		//trace('successCount:$successCount, errorCount:$errorCount');
		if (errorCount + successCount == FileNames.length) {
			trace('complete - loaded $successCount (${FileNames.length}) wavetables');
			trace(waves);
		}
	}
	
	function onDataError(_) {
		errorCount++;
		checkComplete();
	}
}



@:access(CompileTime)
class WavetableFiles {

    macro public static function processData(path:String):ExprOf<{}> {
		
		var data = [];
		var path = Context.resolvePath(path);
		
		if (sys.FileSystem.isDirectory(path)) {
			data = FileSystem.readDirectory(path);
			for (name in data) sys.io.File.copy(path + name, 'bin/wavetables/$name');
		}
		
        return CompileTime.toExpr(data);
    }	
}
