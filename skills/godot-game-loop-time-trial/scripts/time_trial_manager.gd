# time_trial_manager.gd
# [GDSKILLS] godot-game-loop-time-trial
# EXPORT_REFERENCE: time_trial_manager.gd

extends Node

signal lap_started()
signal lap_finished(time: float, is_new_best: bool)
signal checkpoint_passed(index: int, split_time: float)

var best_time: float = INF
var current_lap_time: float = 0.0
var is_racing: bool = false
var current_checkpoint_index: int = -1
var total_checkpoints: int = 0

func setup_track(checkpoints_count: int) -> void:
	total_checkpoints = checkpoints_count
	current_checkpoint_index = -1

func start_lap() -> void:
	current_lap_time = 0.0
	is_racing = true
	current_checkpoint_index = -1
	lap_started.emit()

func pass_checkpoint(index: int) -> void:
	if not is_racing: return
	
	# Linear progression check
	if index == current_checkpoint_index + 1:
		current_checkpoint_index = index
		checkpoint_passed.emit(index, current_lap_time)
		
		if index == total_checkpoints - 1:
			_finish_lap()

func _finish_lap() -> void:
	is_racing = false
	var is_best = current_lap_time < best_time
	if is_best:
		best_time = current_lap_time
	
	lap_finished.emit(current_lap_time, is_best)

func _process(delta: float) -> void:
	if is_racing:
		current_lap_time += delta
