class_name DesktopPerformanceMonitor
extends Node

## Expert OS-level hardware monitoring for PC deployments.
## Used to auto-detect hardware and suggest graphics presets.

func get_hardware_info() -> Dictionary:
	return {
		"cpu": OS.get_processor_name(),
		"ram_total_mb": OS.get_static_memory_usage() / 1024 / 1024, # Current usage
		"gpu": RenderingServer.get_video_adapter_name(),
		"is_sandboxed": OS.is_sandboxed_app()
	}

func suggest_preset() -> StringName:
	# Simplified logic for demonstration
	var gpu = RenderingServer.get_video_adapter_name().to_lower()
	if "rtx" in gpu or "rx 6" in gpu:
		return &"ultra"
	return &"balanced"
