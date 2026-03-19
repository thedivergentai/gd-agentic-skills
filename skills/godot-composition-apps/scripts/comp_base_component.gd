class_name CompBaseComponent
extends Node

## Expert Base Component.
## Job: Encapsulate a single responsibility. Must work "on a rock".

signal task_completed(result: Variant)

func _ready() -> void:
	# Optional: Register to a group for mass orchestration
	add_to_group("Components")

## Rule: NEVER use 'get_parent()' to access data. Use signals or dependency injection.
