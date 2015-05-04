package utils;
import haxe.Http;
import haxe.Json;


/**
 * ...
 * @author Mike Almond - https://github.com/mikedotalmond
 */

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
	public static var Waves		:Array<WavetableData> = [];
	
	public function new() {
		loadAll();
	}
	
	function loadAll() {
		for (name in FileNames) {
			var http:Http = new Http('wavetables/$name');
			http.onData = function(_) {
				var data = Json.parse(_);
				data.name = name.substring(0, name.length - 5);
				Waves.push(cast data);
			};
			http.request();
		}
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
