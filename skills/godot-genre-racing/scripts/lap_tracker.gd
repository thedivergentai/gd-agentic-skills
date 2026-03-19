# lap_tracker.gd
extends Node
class_name LapTracker

# Lap/Time Tracking with Validation
# Sequential checkpoint checks to prevent "cheating" by reversing through the start.

signal lap_completed(total_time: float)

var current_lap := 1
var next_checkpoint_idx := 0
var lap_start_time := 0.0
var checkpoints: Array[Node3D] = []

func _ready() -> void:
    lap_start_time = Time.get_ticks_msec() / 1000.0

func on_checkpoint_passed(checkpoint: Node3D) -> void:
    var idx = checkpoints.find(checkpoint)
    
    # Pattern: Validate sequence to stop lap-shortcuts.
    if idx == next_checkpoint_idx:
        next_checkpoint_idx += 1
        if next_checkpoint_idx >= checkpoints.size():
            _complete_lap()

func _complete_lap() -> void:
    var end_time = Time.get_ticks_msec() / 1000.0
    var lap_time = end_time - lap_start_time
    lap_completed.emit(lap_time)
    
    current_lap += 1
    next_checkpoint_idx = 0
    lap_start_time = end_time
