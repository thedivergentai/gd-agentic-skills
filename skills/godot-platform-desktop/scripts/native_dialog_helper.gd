class_name NativeDialogHelper
extends Node

## Expert native OS integration for desktop platforms.
## Bypasses internal Godot UI for a native UX feel.

func show_native_alert(message: String, title: String = "Alert") -> void:
	# Blocks main thread - use sparingly
	OS.alert(message, title)

func open_native_file_selector(callback: Callable) -> void:
	if DisplayServer.has_feature(DisplayServer.FEATURE_NATIVE_DIALOG_FILE):
		DisplayServer.file_dialog_show(
			"Select File", 
			OS.get_user_data_dir(), 
			"", 
			false, 
			DisplayServer.FILE_DIALOG_MODE_OPEN_FILE, 
			["*.dat; Data Files"],
			callback
		)
	else:
		print("Desktop: Native dialogs not supported on this host.")
