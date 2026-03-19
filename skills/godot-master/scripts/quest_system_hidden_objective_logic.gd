# hidden_objective_logic.gd
# Objectives that aren't visible in the UI
class_name HiddenObjective extends Resource

# EXPERT NOTE: Secret objectives can trigger "Achievement" quests 
# when internal game conditions are met.

signal triggered

@export var required_value: int = 100
var current_value: int = 0

func track_value(val: int):
	current_value += val
	if current_value >= required_value:
		triggered.emit()
