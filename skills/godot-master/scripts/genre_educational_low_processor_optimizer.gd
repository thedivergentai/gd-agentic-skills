# low_processor_optimizer.gd
# Reducing CPU usage for stationary educational screens
extends Node

# EXPERT NOTE: Enabling low_processor_mode saves battery on 
# student laptops during non-animated quiz sections.

func toggle_optimization(enable: bool):
	OS.low_processor_usage_mode = enable
	# Set max sleep if enabled to further reduce draw frequency
	if enable:
		OS.low_processor_usage_mode_sleep_usec = 6900 # ~144hz limit
