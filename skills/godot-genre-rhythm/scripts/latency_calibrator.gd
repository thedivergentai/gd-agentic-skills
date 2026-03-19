# latency_calibrator.gd
extends Node
class_name LatencyCalibrator

# Audio-Visual Offset Correction
# Allows players to adjust the delay between sound and visuals.

var user_offset := 0.0 # Stored in user config

func start_calibration_test() -> void:
    # Measure delta between visual flash and player keypress.
    pass

func apply_offset(conductor: RhythmConductor) -> void:
    # Pattern: Update the conductor's internal offset with calibrated value.
    conductor.offset = user_offset
