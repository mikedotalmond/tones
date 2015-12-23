package js;

import js.html.Event;
import js.html.Uint8Array;

/**
 * Some (incomplete) externs / typedefs for https://github.com/cotejp/webmidi 
 * 
 * @author Mike Almond | https://github.com/mikedotalmond
 */

@:native('WebMidi')
extern class WebMidi {
	
	static function enable (?successHandler:Void->Void, ?errorHandler:String->Void, ?sysex:Bool = false):Void;
	
	static function addListener (type:String, listener:MidiEvent->Void, ?filters:Dynamic):WebMidi;
	static function hasListener (type:String, listener:MidiEvent->Void, ?filters:Dynamic):WebMidi;
	static function removeListener (type:String, listener:MidiEvent->Void, ?filters:Dynamic):WebMidi;
	
	static function getDeviceById (id:String, type:String = "input"):Null<MIDIPort>;
	static function getDeviceIndexById (id:String, type:String = "input"):Null<Int>;
	
	static function noteNameToNumber (name:String):Int;
	
	//static function playNote (id:String, type:String = "input"):WebMidi;
	
	@:overload(function(status:Int, ?data:Array<Int>, ?output:Array<MIDIOutput>, ?timestamp:Float):WebMidi{})
	static function send (status:Int, ?data:Array<Int>, ?output:MIDIOutput, ?timestamp:Float):WebMidi;
	
	//static function sendChannelAftertouch (id:String, type:String = "input"):WebMidi;
	//static function sendChannelMode (id:String, type:String = "input"):WebMidi;
	//static function sendControlChange (id:String, type:String = "input"):WebMidi;
	//static function sendKeyAftertouch (id:String, type:String = "input"):WebMidi;
	//static function sendPitchBend (id:String, type:String = "input"):WebMidi;
	//static function sendProgramChange (id:String, type:String = "input"):WebMidi;
	//static function stopNote (id:String, type:String = "input"):WebMidi;


    static var supported(default, never):Bool;
    static var connected(default, never):Bool;
	
    static var inputs:Array<MIDIInput>;
    static var outputs:Array<MIDIOutput>;
    static var time:DOMHighResTimeStamp;
}


@:native('MIDIPort') 
extern class MIDIPort {
	var id:String;
	var type:String;
	var manufacturer:String;
	var name:String;
	var state:String;
	var connection:String;
	var onstatechange:MIDIConnectionEvent->Void;
	
	@:overload(function(data:Array<UInt>, ?timestamp:Float):Void{})
	function send(data:Uint8Array, ?timestamp:Float):Void;	
}

@:native('MIDIInput')
extern class MIDIInput extends MIDIPort {
	var onmidimessage:MIDIConnectionEvent->Void;
}

@:native('MIDIOutput')
extern class MIDIOutput extends MIDIPort {	
    function clear():Void;
}

@:native('MIDIConnectionEvent')
extern class MIDIConnectionEvent extends Event { 
	var port:Null<Int>;
}

//

typedef MidiNote = {
	var number:Int;
	var name:String;
	var octave:Int;
}

typedef MidiEvent = {
	var device:MIDIInput;
	var data:Uint8Array;
    var receivedTime:Float;
    var timeStamp:Int;
    var type:String;
	@:optional var value:Float;
}

typedef MidiNoteEvent = {> MidiEvent,
	var channel:Int;
	var note:MidiNote;
	var velocity:Float;
}

typedef DOMHighResTimeStamp = Float;

