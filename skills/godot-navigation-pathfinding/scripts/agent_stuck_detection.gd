# agent_stuck_detection.gd
# Advanced stuck detection for robust AI movement
extends Node3D

var last_position: Vector3
var stuck_time: float = 0.0
@export var stuck_threshold: float = 0.1
@export var stuck_timeout: float = 1.0

func _check_stuck(current_pos: Vector3, delta: float) -> bool:
	if current_pos.distance_to(last_position) < stuck_threshold:
		stuck_time += delta
	else:
		stuck_time = 0.0
	
	last_position = current_pos
	
	if stuck_time > stuck_timeout:
		# AI is likely blocked or stuck in geometry
		return true
	return false

func handle_recovery(agent: NavigationAgent3D) -> void:
	# Recovery logic: Teleport slightly, recalculate path, or bump velocity
	var random_bump = Vector3(randf_range(-1,1), 0, randf_range(-1,1)).normalized()
	# agent.target_position = ...
	stuck_time = 0.0
