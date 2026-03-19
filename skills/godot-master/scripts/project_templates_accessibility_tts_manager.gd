class_name AccessibilityTTSManager
extends Node

## Accessibility & Localization foundation for modern templates.
## Utilizes DisplayServer for native TTS and TranslationServer for i18n context.

func speak_ui_element(text: String, context: StringName = &"") -> void:
	# Use context to ensure the correct translation (e.g. "Lead" metal vs "Lead" action)
	var translated := TranslationServer.translate(text, context)
	
	if DisplayServer.tts_is_speaking():
		DisplayServer.tts_stop()
		
	# Trigger system-level screen reader / TTS
	var voices = DisplayServer.tts_get_voices()
	if not voices.is_empty():
		DisplayServer.tts_speak(translated, voices[0]["id"])

## Tool tip for templates: Use 'set_input_as_handled' in accessibility overlays.
