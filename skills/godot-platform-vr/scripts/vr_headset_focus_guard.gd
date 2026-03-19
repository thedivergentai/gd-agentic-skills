class_name VRHeadsetFocusGuard
extends Node

## Expert handler for VR headset focus events.
## Prevents the game from running while the user is in the system menu.

func _notification(what: int) -> void:
	match what:
		NOTIFICATION_WM_WINDOW_FOCUS_OUT:
			# Headset removed or system overlay (Meta menu) opened
			get_tree().paused = true
			_silence_audio(true)
		NOTIFICATION_WM_WINDOW_FOCUS_IN:
			get_tree().paused = false
			_silence_audio(false)

func _silence_audio(muted: bool) -> void:
	AudioServer.set_bus_mute(0, muted)
