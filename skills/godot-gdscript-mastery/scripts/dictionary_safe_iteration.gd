# dictionary_safe_iteration.gd
# Correct pattern for deleting keys during iteration
extends Node

func cleanup_expired_data(data: Dictionary):
	# NEVER erase from the dict while iterating it directly.
	# Create a copy of keys to iterate instead.
	var keys_to_check = data.keys()
	
	for key in keys_to_check:
		if _is_expired(data[key]):
			data.erase(key) # Safe because we iterate the clone

func _is_expired(_val) -> bool:
	return true
