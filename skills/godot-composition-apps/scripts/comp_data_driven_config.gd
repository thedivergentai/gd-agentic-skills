class_name CompDataDrivenConfig
extends Node

## Expert Resource-driven Component configuration.
## Allows behavior to be hot-swapped via .tres files.

@export var config: Resource

func _ready() -> void:
	if config:
		_apply_config()

func _apply_config() -> void:
	# Pattern: Access properties from the Resource.
	# Example: parent.speed = config.movement_speed
	pass

## Rule: Decouple 'Values' (Resource) from 'Logic' (Component).
