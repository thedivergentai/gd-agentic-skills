class_name LowProcessorEcoMode
extends Node

## Expert Eco Mode/Low Processor usage optimization.
## Ideal for desktop utilities, launchers, or laptop-friendly settings.

func set_eco_mode(enabled: bool) -> void:
	# Only redraw if something changes (animations, input)
	OS.low_processor_usage_mode = enabled
	
	if enabled:
		# Increase sleep time between frames to reduce CPU heat
		OS.low_processor_usage_mode_sleep_usec = 8000
	else:
		OS.low_processor_usage_mode_sleep_usec = 6900 # Default

## Tip: This can reduce GPU power draw by up to 90% in idle/static UI apps.
