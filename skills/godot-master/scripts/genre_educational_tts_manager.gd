# tts_manager.gd
# Utilizing Godot's built-in Text-to-Speech for accessibility
extends Node

# EXPERT NOTE: DisplayServer.tts_spoke() provides native 
# OS-level accessibility support for visually impaired students.

func speak_question(text: String):
	var voices = DisplayServer.tts_get_voices_for_language("en")
	if !voices.is_empty():
		DisplayServer.tts_speak(text, voices[0])

func stop_speech():
	DisplayServer.tts_stop()
