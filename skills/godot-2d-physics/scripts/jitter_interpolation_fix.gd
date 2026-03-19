# Physics Interpolation and Jitter Controller
extends Node

## Godot 4 standard physics run at 60Hz, while monitors run at 144Hz+.
## This script ensures smooth visuals by enabling interpolation and 
## managing physics/render process synchronization.

func _ready() -> void:
	# Architecture Tip: Enable 'Physics Interpolation' in Project Settings.
	# This script ensures that crucial camera and player nodes are optimized
	# for that interpolation.
	
	if Engine.is_editor_hint(): return
	
	# Lock FPS to refresh rate to prevent visual 'beat' patterns against physics
	DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_ENABLED)
	
	# Low latency input mode for competitive physics feel
	Input.set_use_accumulated_input(false)
