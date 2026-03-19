class_name RuntimeConfigurator
extends Node

## Expert pattern for applying high-performance profiles and saving override.cfg.
## This allows dynamic adjustments to ticks, FPS, and window modes while persisting them.

static func apply_high_performance_profile() -> void:
	# High-tick physics for competitive/sports games
	Engine.max_fps = 144
	Engine.physics_ticks_per_second = 120
	
	# Window settings must be routed through the DisplayServer for immediate effect
	DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN)
	
	# Setting persistence via override.cfg [Standard Godot startup override]
	ProjectSettings.set_setting("application/run/max_fps", 144)
	ProjectSettings.set_setting("physics/common/physics_ticks_per_second", 120)
	
	# Only call this in tools or at specific "Apply" moments to avoid I/O blocking
	ProjectSettings.save_custom("user://override.cfg")

static func apply_battery_saver_profile() -> void:
	Engine.max_fps = 30
	Engine.physics_ticks_per_second = 60
	DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
	
	ProjectSettings.set_setting("application/run/max_fps", 30)
	ProjectSettings.save_custom("user://override.cfg")
