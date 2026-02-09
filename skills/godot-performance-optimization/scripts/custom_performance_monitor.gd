# skills/performance-optimization/scripts/custom_performance_monitor.gd
extends Node

## Custom Performance Monitor Expert Pattern
## Adds game-specific metrics to the Godot Debugger > Monitors tab.

class_name CustomPerformanceMonitor

enum MonitorType {
	ENEMY_COUNT,
	ACTIVE_PROJECTILES,
	PATHFINDING_TIME_MS,
	CHUNK_LOAD_TIME_MS
}

# Map enum to readable names
var _monitor_names = {
	MonitorType.ENEMY_COUNT: "Game/Enemy Count",
	MonitorType.ACTIVE_PROJECTILES: "Game/Active Projectiles",
	MonitorType.PATHFINDING_TIME_MS: "Game/Pathfinding (ms)",
	MonitorType.CHUNK_LOAD_TIME_MS: "Game/Chunk Load (ms)"
}

var _monitor_values = {}

func _ready() -> void:
	# Only run in debug builds
	if not OS.is_debug_build():
		queue_free()
		return
		
	# Register monitors
	for type in _monitor_names:
		var path = _monitor_names[type]
		if not Performance.has_custom_monitor(path):
			Performance.add_custom_monitor(path, _get_monitor_value.bind(type))
			_monitor_values[type] = 0.0

func update_monitor(type: MonitorType, value: float) -> void:
	if OS.is_debug_build():
		_monitor_values[type] = value

func increment_monitor(type: MonitorType, amount: float = 1.0) -> void:
	if OS.is_debug_build():
		if type in _monitor_values:
			_monitor_values[type] += amount
		else:
			_monitor_values[type] = amount

func _get_monitor_value(type: MonitorType) -> float:
	return _monitor_values.get(type, 0.0)

## EXPERT USAGE:
## CustomPerformanceMonitor.update_monitor(CustomPerformanceMonitor.MonitorType.ENEMY_COUNT, enemies.size())
