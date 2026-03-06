# game_loop_time_trial_recorder.gd
# [GDSKILLS] godot-game-loop-time-trial
# EXPORT_REFERENCE: ghost_recorder.gd

extends Node

@export var target_node: Node3D
@export var sample_rate: float = 0.1 # Seconds between samples

var recording: Array = []
var is_recording: bool = false
var time_elapsed: float = 0.0
var last_sample_time: float = 0.0

func start_recording() -> void:
	recording.clear()
	is_recording = true
	time_elapsed = 0.0
	last_sample_time = 0.0

func stop_recording() -> void:
	is_recording = false

func _physics_process(delta: float) -> void:
	if not is_recording or not target_node:
		return
		
	time_elapsed += delta
	if time_elapsed >= last_sample_time + sample_rate:
		_capture_sample()
		last_sample_time = time_elapsed

func _capture_sample() -> void:
	recording.append({
		"t": time_elapsed,
		"p": target_node.global_position,
		"r": target_node.global_rotation
	})

func get_data() -> Array:
	return recording
