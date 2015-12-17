package tones;

import js.Browser;
import js.Error;
import js.html.ArrayBuffer;
import js.html.audio.AudioBuffer;
import js.html.audio.AudioContext;
import js.html.audio.AudioNode;
import js.html.AudioElement;
import js.html.Event;
import js.html.XMLHttpRequest;
import js.html.XMLHttpRequestResponseType;


/**
 * ...
 * @author bit101 - https://github.com/bit101/tones
 * @author Mike Almond - https://github.com/mikedotalmond
 */

class Samples extends AudioBase {

	public var buffer(get, set):AudioBuffer;
	public var playbackRate:Float;
	public var offset:Float;

	var _buffer:AudioBuffer = null;
	inline function get_buffer() return _buffer;
	function set_buffer(value:AudioBuffer):AudioBuffer {
		offset = 0;
		duration = value.duration;
		return _buffer = value;
	}


	/**
	 * @param	audioContext 	- optional. Pass an exsiting audioContext here to share it.
	 * @param	destinationNode - optional. Pass a custom destination AudioNode to connect to.
	 */
	public function new(audioContext:AudioContext = null, ?destinationNode:AudioNode = null) {
		super(audioContext, destinationNode);
		playbackRate = 1.0;
		offset = 0;
	}
	

	/**
	 * Play a sample
	 * sample.playSample(); // play the currently set buffer 
	 * sample.playSample(myBuffer); // play the myBuffer sample
	 * sample.playSample(myBuffer, 1); // play the myBuffer sample, in one second
	 * sample.playSample(myBuffer, 1, false); // play the myBuffer sample, in one second, and doesn't release untill you call doRelease(toneId)
	 *
	 * @param	newBuffer	- The AudioBuffer to play from (optional if you've already set the .buffer value before calling playSample)
	 * @param	delayBy		- A time, in seconds, to delay triggering this sample by.
	 * @param	autoRelease - Release as soon as attack phase ends - default behaviour (true)
	 * 						  when false the sample will play until doRelease(sampleId) is called
	 * 						- Don't use these behaviours at the same time in one Samples instance
	 * @return 	id			- The ID assigned to the tone being played. Use for doRelease() when using autoRelease=false
	 */
    public function playSample(newBuffer:AudioBuffer = null, delayBy:Float = .0):Int {

		if (newBuffer != null) buffer = newBuffer;
		if (buffer == null) throw 'The source AudioBuffer is null.';
		
		if (delayBy < 0) delayBy = 0;
		
		var id = nextID();
		
		var triggerTime = now + delayBy;
		var envelope = createAttackEnvelope(triggerTime);
		
		//
		var src = context.createBufferSource();
		src.buffer = this.buffer;
		src.playbackRate.value = playbackRate;
		
		if (offset < 0) offset = 0;
		if (duration <= sampleTime || offset + duration > buffer.duration) duration = buffer.duration - offset;
		
		src.connect(envelope);
		src.start(triggerTime, offset, duration);
		
		setActiveItem(id, src, envelope, delayBy, triggerTime, true);
		
		return id;
	}
	
	
	
	/**
	 * 
	 * @param	url
	 * @param	onLoad
	 * @param	onError
	 */
	public static function loadArrayBuffer(url:String,  onLoad:ArrayBuffer->Void, onProgress:Float->Void=null, onError:Error->Void = null) {
		
		var request = new XMLHttpRequest();
		request.open("GET", url, true);
		request.responseType = XMLHttpRequestResponseType.ARRAYBUFFER;
		
		request.onerror = onError;
		request.onload = function(_) onLoad(_.currentTarget.response);
		if (onProgress != null) {
			request.onprogress = function(_) {
				var percent = Math.NaN;
				if (_.lengthComputable) percent = _.loaded / _.total;
				onProgress(percent);
			};
		}
		
		request.send();
	}
	
	
	/**
	 * 
	 * @param	buffer
	 * @param	context
	 * @param	onDecoded
	 * @param	onError
	 */
	public static function decodeArrayBuffer(buffer:ArrayBuffer, context:AudioContext, onDecoded:AudioBuffer->Void, onError:Error->Void = null) {
		try {
			context.decodeAudioData(buffer, onDecoded);
		} catch (err:Error) {
			if (onError != null) onError(err);
			else throw err;
		}
	}		
	
	
	/**
	 * I don't particularly like the responses (probably/maybe/no/[empty]) from mediaElement.canPlayType
	 * 
	 * This function is optimistic, and will assume that 'probably' and 'maybe' actaully mean 'yes'.
	 * Debug builds will print out the actual string result from canPlayType()
	 *
	 * canPlayType('audio/ogg')
	 * canPlayType('video/ogg')
	 * canPlayType('video/ogg', 'theora, vorbis')
	 * canPlayType('video/webm', 'vp8')
	 * 
	 * @param	mimeType
	 * @param	codecType 
	 * @return	true/false - true if 'probably' or 'maybe', false if 'no' or empty result.
	 */
	public static function canPlayType(mimeType:String, codecType:String = ''):Bool {
		var result = audioTester == null ? '' : audioTester.canPlayType('$mimeType;codecs="$codecType"');
		#if debug 
		trace('Samples.canPlayType $mimeType;codecs="$codecType" = $result');
		#end
		return (result == 'no' || result.length == 0) ? false : true;
	}
	
	
	
	@:noCompletion static function __init__() {
		audioTester = try {
			Browser.document.createAudioElement();
		} catch (err:Error) {
			null;
		}
	}
	
	@:noCompletion static var audioTester:AudioElement = null;
}