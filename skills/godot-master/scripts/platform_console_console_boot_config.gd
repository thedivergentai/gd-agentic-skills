class_name ConsoleBootConfig
extends Node

## Expert hardware-aware boot configuration.
## Disables expensive PC-only rendering features on initialization.

func _ready() -> void:
	if OS.has_feature("mobile") or OS.has_feature("switch"):
		_optimize_for_low_end()
	
	# TRC Requirement: Always enable VSync for consoles
	DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_ENABLED)

func _optimize_for_low_end() -> void:
	# Disable real-time global illumination for performance
	RenderingServer.gi_set_use_half_resolution(true)
	# Lock FPS to prevent heating
	Engine.max_fps = 30
