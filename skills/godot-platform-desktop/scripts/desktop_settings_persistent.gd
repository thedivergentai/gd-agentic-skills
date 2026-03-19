class_name DesktopSettingsPersistent
extends Node

## Expert settings persistence using ConfigFile.
## Stores window state and graphics presets in a standard INI format.

const SETTINGS_PATH = "user://settings.ini"
var _config := ConfigFile.new()

func save_desktop_state() -> void:
	var window := get_window()
	_config.set_value("display", "screen", window.current_screen)
	_config.set_value("display", "mode", window.mode)
	_config.set_value("display", "size", window.size)
	_config.set_value("display", "position", window.position)
	
	var err = _config.save(SETTINGS_PATH)
	if err != OK:
		push_error("DesktopSettings: Failed to save to ", SETTINGS_PATH)

func load_desktop_state() -> void:
	if _config.load(SETTINGS_PATH) == OK:
		var window := get_window()
		window.current_screen = _config.get_value("display", "screen", window.current_screen)
		window.mode = _config.get_value("display", "mode", window.mode)
		# Expert: Only apply size/pos if windowed to avoid resolution corruption
		if window.mode == Window.MODE_WINDOWED:
			window.size = _config.get_value("display", "size", window.size)
			window.position = _config.get_value("display", "position", window.position)
