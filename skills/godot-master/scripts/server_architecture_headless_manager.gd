# godot-master/scripts/server_architecture_headless_manager.gd
extends Node

## Headless Server Manager Expert Pattern
## Manages headless state, arguments, and optimizations for dedicated servers.

class_name HeadlessManager

signal server_ready
signal server_shutdown

func _ready() -> void:
	# 1. Detect Headless Mode
	if DisplayServer.get_name() == "headless":
		print("[HeadlessManager] Running in Headless Mode")
		_configure_headless()
	else:
		print("[HeadlessManager] Running in Graphical Mode")
	
	# 2. Parse Arguments
	_parse_cmdline_args()

func _configure_headless() -> void:
	# Disable visual-only processing if necessary
	# Note: Godot 4 headless automatically disables rendering, but we can save more
	
	# Limit physics if not needed, or lock FPS
	Engine.max_fps = 60 # Server tick rate
	
	# Lower audio bus volume or disable
	AudioServer.set_bus_mute(0, true)

func _parse_cmdline_args() -> void:
	var args = OS.get_cmdline_user_args()
	for arg in args:
		if arg.begins_with("--port="):
			var port = arg.split("=")[1].to_int()
			print("[HeadlessManager] Override Port: ", port)
			# NetworkManager.start_server(port)

func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		print("[HeadlessManager] Shutdown Requested")
		server_shutdown.emit()
		# Perform cleanup
		# Save state
		get_tree().quit()

## EXPERT USAGE:
## Add as AutoLoad. Call using standard --headless -- --port=7777
