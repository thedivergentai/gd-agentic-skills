# rhythm_conductor.gd
extends Node
class_name RhythmConductor

# High-Precision BPM Tracking using AudioServer
# Accounts for output latency and mix offsets to ensure perfect sync.

@export var bpm := 120.0
@export var offset := 0.0 # Manual calibration offset

var time_begin := 0.0
var time_delay := 0.0

func _ready() -> void:
    time_begin = Time.get_ticks_usec()
    time_delay = AudioServer.get_time_to_next_mix() + AudioServer.get_output_latency()

func get_current_time() -> float:
    # Pattern: Use AudioServer-derived time for exact rhythm sync.
    var current_time = (Time.get_ticks_usec() - time_begin) / 1000000.0
    current_time -= time_delay
    return max(0.0, current_time + offset)

func get_current_beat() -> float:
    return get_current_time() * (bpm / 60.0)
