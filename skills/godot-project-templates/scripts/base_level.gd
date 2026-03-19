class_name BaseLevel
extends Node

## Abstract base class for all loaded levels.
## Provides structured lifecycle hooks for initialization and completion.

signal level_initialized
signal level_completed(next_level_id: StringName)

@export var level_id: StringName

func _ready() -> void:
	# Standardize startup sequence
	_initialize_level()
	level_initialized.emit()

## Virtual method: Override for level-specific setup (NPC spawning, etc.)
func _initialize_level() -> void:
	pass

## Expert: Use call_deferred to safely transition scenes and avoid physics-mid-frame errors.
func complete_level(next_id: StringName = &"") -> void:
	call_deferred(&"_deferred_completion", next_id)

func _deferred_completion(next_id: StringName) -> void:
	level_completed.emit(next_id if not next_id.is_empty() else level_id)
