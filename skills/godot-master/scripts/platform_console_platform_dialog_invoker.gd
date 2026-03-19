class_name PlatformDialogInvoker
extends Node

## Abstract interface for native Console dialogs (Keyboard, Prompts).
## Detects the platform and routes to the appropriate OS handler.

func show_virtual_keyboard(title: String, existing_text: String = "") -> void:
	if OS.has_feature("mobile") or OS.has_feature("console"):
		# Expert: DisplayServer.virtual_keyboard_show handles most platform-native input
		DisplayServer.virtual_keyboard_show(existing_text, Rect2(0,0,0,0))
	else:
		# PC Fallback for dev testing
		pass

func show_system_dialog(title: String, message: String) -> void:
	# Implementation varies by native GDExtension bridge
	pass
