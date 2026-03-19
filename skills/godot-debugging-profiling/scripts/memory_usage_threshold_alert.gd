# memory_usage_threshold_alert.gd
# Catching memory bloat early
extends Node

# EXPERT NOTE: Monitor static memory and push a warning 
# if it exceeds a project-defined threshold.

const MEMORY_LIMIT_MB = 1024

func _physics_process(_delta):
	var usage_mb = Performance.get_monitor(Performance.MEMORY_STATIC) / 1024 / 1024
	if usage_mb > MEMORY_LIMIT_MB:
		push_warning("MEMORY USAGE HIGH: ", usage_mb, "MB")
