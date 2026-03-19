class_name SecretProgressThresholdUnlocker
extends Node

## Expert Progress-Based Secret Trigger.
## Unlocks hidden content when game completion % reaches a threshold.

@export var required_completion_percent: float = 100.0

func check_unlock() -> bool:
	var current_percent = GlobalStats.get_completion_percent()
	if current_percent >= required_completion_percent:
		_perform_unlock()
		return true
	return false

func _perform_unlock() -> void:
	print("Secret True Ending Unlocked.")

## Tip: Use '100% Completion' triggers specifically for non-gameplay meta-content (e.g., concept art).
