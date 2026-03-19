# push_error_safe_exit.gd
# Reporting errors without crashing the engine
extends Node

# EXPERT NOTE: push_error() sends to the Godot console 
# and debugger without stopping execution like assert().

func load_critical_config(path: String):
	if not FileAccess.file_exists(path):
		push_error("CRITICAL CONFIG MISSING: ", path)
		# Fallback to default avoid crash
		return _generate_default_config()
	
	return load(path)

func _generate_default_config():
	return {}
