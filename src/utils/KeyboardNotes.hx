﻿package utils;

/**
 * Map keys on a QWERTY keyboard to musical keyboard notes and frequencies
 *
 * @author Mike Almond
 */

import input.KeyCodes;
import js.html.Float32Array;
import utils.NoteFrequencyUtil;

class KeyboardNotes {
	
	public var startOctave(default, null):Int;
	public var noteFreq(default, null):NoteFrequencyUtil;
	public var keycodeToNoteFreq(default, null):Map<Int,Float>;
	public var keycodeToNoteIndex(default, null):Map<Int,Int>;
		
	public function new(startOctave:Int = 0) {
		
		this.startOctave	= startOctave;
		
		noteFreq 			= new NoteFrequencyUtil();		
		keycodeToNoteFreq 	= new Map<Int,Float>();
		keycodeToNoteIndex 	= new Map<Int,Int>();
		
		keycodeToNoteIndex.set(KeyCodes.Z, noteFreq.noteNameToIndex('C${startOctave}'));
		keycodeToNoteIndex.set(KeyCodes.S, noteFreq.noteNameToIndex('C#${startOctave}'));
		keycodeToNoteIndex.set(KeyCodes.X, noteFreq.noteNameToIndex('D${startOctave}'));
		keycodeToNoteIndex.set(KeyCodes.D, noteFreq.noteNameToIndex('D#${startOctave}'));
		keycodeToNoteIndex.set(KeyCodes.C, noteFreq.noteNameToIndex('E${startOctave}'));
		keycodeToNoteIndex.set(KeyCodes.V, noteFreq.noteNameToIndex('F${startOctave}'));
		keycodeToNoteIndex.set(KeyCodes.G, noteFreq.noteNameToIndex('F#${startOctave}'));
		keycodeToNoteIndex.set(KeyCodes.B, noteFreq.noteNameToIndex('G${startOctave}'));
		keycodeToNoteIndex.set(KeyCodes.H, noteFreq.noteNameToIndex('G#${startOctave}'));
		keycodeToNoteIndex.set(KeyCodes.N, noteFreq.noteNameToIndex('A${startOctave}'));
		keycodeToNoteIndex.set(KeyCodes.J, noteFreq.noteNameToIndex('A#${startOctave}'));
		keycodeToNoteIndex.set(KeyCodes.M, noteFreq.noteNameToIndex('B${startOctave}'));
		keycodeToNoteIndex.set(KeyCodes.Q, noteFreq.noteNameToIndex('C${startOctave+1}'));
		keycodeToNoteIndex.set(KeyCodes.NUMBER_2, noteFreq.noteNameToIndex('C#${startOctave+1}'));
		keycodeToNoteIndex.set(KeyCodes.W, noteFreq.noteNameToIndex('D${startOctave+1}'));
		keycodeToNoteIndex.set(KeyCodes.NUMBER_3, noteFreq.noteNameToIndex('D#${startOctave+1}'));
		keycodeToNoteIndex.set(KeyCodes.E, noteFreq.noteNameToIndex('E${startOctave+1}'));
		keycodeToNoteIndex.set(KeyCodes.R, noteFreq.noteNameToIndex('F${startOctave+1}'));
		keycodeToNoteIndex.set(KeyCodes.NUMBER_5, noteFreq.noteNameToIndex('F#${startOctave+1}'));
		keycodeToNoteIndex.set(KeyCodes.T, noteFreq.noteNameToIndex('G${startOctave+1}'));
		keycodeToNoteIndex.set(KeyCodes.NUMBER_6, noteFreq.noteNameToIndex('G#${startOctave+1}'));
		keycodeToNoteIndex.set(KeyCodes.Y, noteFreq.noteNameToIndex('A${startOctave+1}'));
		keycodeToNoteIndex.set(KeyCodes.NUMBER_7, noteFreq.noteNameToIndex('A#${startOctave+1}'));
		keycodeToNoteIndex.set(KeyCodes.U, noteFreq.noteNameToIndex('B${startOctave+1}'));
		keycodeToNoteIndex.set(KeyCodes.I, noteFreq.noteNameToIndex('C${startOctave+2}'));
		keycodeToNoteIndex.set(KeyCodes.NUMBER_9, noteFreq.noteNameToIndex('C#${startOctave+2}'));
		keycodeToNoteIndex.set(KeyCodes.O, noteFreq.noteNameToIndex('D${startOctave+2}'));
		keycodeToNoteIndex.set(KeyCodes.NUMBER_0, noteFreq.noteNameToIndex('D#${startOctave+2}'));
		keycodeToNoteIndex.set(KeyCodes.P, noteFreq.noteNameToIndex('E${startOctave+2}'));
		keycodeToNoteIndex.set(KeyCodes.LEFT_BRACKET, noteFreq.noteNameToIndex('F${startOctave+2}'));
		keycodeToNoteIndex.set(KeyCodes.EQUALS, noteFreq.noteNameToIndex('F#${startOctave+2}'));
		keycodeToNoteIndex.set(KeyCodes.RIGHT_BRACKET, noteFreq.noteNameToIndex('G${startOctave+2}'));
		
		keycodeToNoteFreq.set(KeyCodes.Z, keycodeToNoteIndex.get(KeyCodes.Z));
		keycodeToNoteFreq.set(KeyCodes.S, keycodeToNoteIndex.get(KeyCodes.S));
		keycodeToNoteFreq.set(KeyCodes.X, keycodeToNoteIndex.get(KeyCodes.X));
		keycodeToNoteFreq.set(KeyCodes.D, keycodeToNoteIndex.get(KeyCodes.D));
		keycodeToNoteFreq.set(KeyCodes.C, keycodeToNoteIndex.get(KeyCodes.C));
		keycodeToNoteFreq.set(KeyCodes.V, keycodeToNoteIndex.get(KeyCodes.V));
		keycodeToNoteFreq.set(KeyCodes.G, keycodeToNoteIndex.get(KeyCodes.G));
		keycodeToNoteFreq.set(KeyCodes.B, keycodeToNoteIndex.get(KeyCodes.B));
		keycodeToNoteFreq.set(KeyCodes.H, keycodeToNoteIndex.get(KeyCodes.H));
		keycodeToNoteFreq.set(KeyCodes.N, keycodeToNoteIndex.get(KeyCodes.N));
		keycodeToNoteFreq.set(KeyCodes.J, keycodeToNoteIndex.get(KeyCodes.J));
		keycodeToNoteFreq.set(KeyCodes.M, keycodeToNoteIndex.get(KeyCodes.M));
		keycodeToNoteFreq.set(KeyCodes.Q, keycodeToNoteIndex.get(KeyCodes.Q));
		keycodeToNoteFreq.set(KeyCodes.NUMBER_2, keycodeToNoteIndex.get(KeyCodes.NUMBER_2));
		keycodeToNoteFreq.set(KeyCodes.W, keycodeToNoteIndex.get(KeyCodes.W));
		keycodeToNoteFreq.set(KeyCodes.NUMBER_3, keycodeToNoteIndex.get(KeyCodes.NUMBER_3));
		keycodeToNoteFreq.set(KeyCodes.E, keycodeToNoteIndex.get(KeyCodes.E));
		keycodeToNoteFreq.set(KeyCodes.R, keycodeToNoteIndex.get(KeyCodes.R));
		keycodeToNoteFreq.set(KeyCodes.NUMBER_5, keycodeToNoteIndex.get(KeyCodes.NUMBER_5));
		keycodeToNoteFreq.set(KeyCodes.T, keycodeToNoteIndex.get(KeyCodes.T));
		keycodeToNoteFreq.set(KeyCodes.NUMBER_6, keycodeToNoteIndex.get(KeyCodes.NUMBER_6));
		keycodeToNoteFreq.set(KeyCodes.Y, keycodeToNoteIndex.get(KeyCodes.Y));
		keycodeToNoteFreq.set(KeyCodes.NUMBER_7, keycodeToNoteIndex.get(KeyCodes.NUMBER_7));
		keycodeToNoteFreq.set(KeyCodes.U, keycodeToNoteIndex.get(KeyCodes.U));
		keycodeToNoteFreq.set(KeyCodes.I, keycodeToNoteIndex.get(KeyCodes.I));
		keycodeToNoteFreq.set(KeyCodes.NUMBER_9, keycodeToNoteIndex.get(KeyCodes.NUMBER_9));
		keycodeToNoteFreq.set(KeyCodes.O, keycodeToNoteIndex.get(KeyCodes.O));
		keycodeToNoteFreq.set(KeyCodes.NUMBER_0, keycodeToNoteIndex.get(KeyCodes.NUMBER_0));
		keycodeToNoteFreq.set(KeyCodes.P, keycodeToNoteIndex.get(KeyCodes.P));
		keycodeToNoteFreq.set(KeyCodes.LEFT_BRACKET, keycodeToNoteIndex.get(KeyCodes.LEFT_BRACKET));
		keycodeToNoteFreq.set(KeyCodes.EQUALS, keycodeToNoteIndex.get(KeyCodes.EQUALS));
		keycodeToNoteFreq.set(KeyCodes.RIGHT_BRACKET, keycodeToNoteIndex.get(KeyCodes.RIGHT_BRACKET));
	}
	
	public function dispose() {
		noteFreq 			= null;
		keycodeToNoteFreq 	= null;
		keycodeToNoteIndex 	= null;
	}
}