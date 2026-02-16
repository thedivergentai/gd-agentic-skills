# godot-master/scripts/debugging_profiling_debug_overlay.gd
extends CanvasLayer

## Debug Overlay Expert Pattern
## In-game debug UI for performance monitoring and state inspection.

class_name DebugOverlay

@onready var label := Label.new()
var _update_interval: float = 0.5
var _time_since_update: float = 0.0
var _custom_metrics: Dictionary = {}

func _ready() -> void:
	# Setup label
	label.position = Vector2(10, 10)
	label.add_theme_font_size_override("font_size", 14)
	label.add_theme_color_override("font_color", Color.YELLOW)
	label.add_theme_color_override("font_outline_color", Color.BLACK)
	label.add_theme_constant_override("outline_size", 2)
	add_child(label)
	
	# Only visible in debug builds
	visible = OS.is_debug_build()

func _process(delta: float) -> void:
	_time_since_update += delta
	
	if _time_since_update >= _update_interval:
		_update_overlay()
		_time_since_update = 0.0

func _update_overlay() -> void:
	var fps := Engine.get_frames_per_second()
	var mem := Performance.get_monitor(Performance.MEMORY_STATIC) / 1024.0 / 1024.0
	var objects := Performance.get_monitor(Performance.OBJECT_COUNT)
	var orphans := Performance.get_monitor(Performance.OBJECT_ORPHAN_NODE_COUNT)
	
	var text := "FPS: %d\n" % fps
	text += "Memory: %.1f MB\n" % mem
	text += "Objects: %d\n" % objects
	
	if orphans > 0:
		text += "⚠️ Orphans: %d\n" % orphans
	
	# Custom metrics
	for key in _custom_metrics:
		text += "%s: %s\n" % [key, str(_custom_metrics[key])]
	
	label.text = text

func add_metric(key: String, value) -> void:
	_custom_metrics[key] = value

func remove_metric(key: String) -> void:
	_custom_metrics.erase(key)

## EXPERT USAGE:
## Add as autoload: DebugOverlay
## DebugOverlay.add_metric("Enemies", enemy_count)
## DebugOverlay.add_metric("Player Health", player.health)
##
## Press F12 to toggle: DebugOverlay.visible = !DebugOverlay.visible
