# secure_variable_synchronizer.gd
# Authority-only variable updates
extends Node

# EXPERT NOTE: Never let clients dictate their own health 
# or money. Only the server updates these variables.

@export var health: int = 100:
	set(val):
		health = val
		health_changed.emit(val)

signal health_changed(new_val)

func damage(amount: int):
	# Damage logic should only execute on the server
	if not multiplayer.is_server(): return
	health -= amount
	# Update will replicate automatically if using Synchronizer
