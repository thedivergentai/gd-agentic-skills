# skills/platform-desktop/scripts/desktop_integration_manager.gd
extends Node

## Desktop Integration Manager Expert Pattern
## Handles window management, Steam integration (mocked), and quit requests.

class_name DesktopIntegrationManager

signal settings_changed
signal app_quit_requested

# Configuration
const SETTINGS_PATH = "user://settings.cfg"

# State
var _config := ConfigFile.new()

func _ready() -> void:
	# 1. Handle Quit Requests (Alt+F4, Cmd+Q)
	get_tree().set_auto_accept_quit(false)
	
	# 2. Load Settings
	_load_settings()
	_apply_graphics_settings()
	
	# 3. Initialize Steam (Mock/Check)
	_init_steam()
	
	print("[DesktopIntegrationManager] Initialized")

func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		_handle_quit_request()

func _handle_quit_request() -> void:
	print("[DesktopIntegrationManager] Quit Requested")
	# Perform saves, cleanup, etc.
	app_quit_requested.emit()
	
	# Force quit after delay if needed, or let game logic call quit
	get_tree().quit()

func set_resolution(index: int) -> void:
	var resolutions = [
		Vector2i(1920, 1080),
		Vector2i(2560, 1440),
		Vector2i(3840, 2160)
	]
	
	if index >= 0 and index < resolutions.size():
		var res = resolutions[index]
		get_window().size = res
		_center_window()
		
		_config.set_value("graphics", "resolution_index", index)
		_save_settings()

func set_fullscreen(enabled: bool) -> void:
	if enabled:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN) # Or EXCLUSIVE
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
		_center_window()
	
	_config.set_value("graphics", "fullscreen", enabled)
	_save_settings()

func _center_window() -> void:
	var screen_id = DisplayServer.window_get_current_screen()
	var screen_rect = DisplayServer.screen_get_usable_rect(screen_id)
	var window_size = get_window().size
	get_window().position = screen_rect.position + (screen_rect.size - window_size) / 2

func _init_steam() -> void:
	if Engine.has_singleton("Steam"):
		var steam = Engine.get_singleton("Steam")
		var init_info: Dictionary = steam.steamInit()
		print("[DesktopIntegrationManager] Steam Status: ", init_info.get("verbal", "Unknown"))
	else:
		print("[DesktopIntegrationManager] Steamworks SDK not found (Development Mode)")

func _load_settings() -> void:
	if _config.load(SETTINGS_PATH) != OK:
		# Defaults
		_config.set_value("graphics", "resolution_index", 0)
		_config.set_value("graphics", "fullscreen", false)
		_save_settings()

func _save_settings() -> void:
	_config.save(SETTINGS_PATH)

func _apply_graphics_settings() -> void:
	set_resolution(_config.get_value("graphics", "resolution_index", 0))
	set_fullscreen(_config.get_value("graphics", "fullscreen", false))

## EXPERT USAGE:
## Add as AutoLoad. Connect to settings menu UI.
