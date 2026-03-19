@icon("res://icons/data_resource.svg")
class_name BaseDataResource
extends Resource

## Reactive Resource foundation for scalability.
## Centralizes data-driven triggers by emitting changed signals on property setters.

@export_group("Identity")
@export var id: StringName
@export var display_name: String = "New Item"

@export_group("Statistics")
@export var base_value: float = 1.0:
	set(v):
		base_value = v
		emit_changed()

@export var metadata: Dictionary = {}:
	set(v):
		metadata = v
		emit_changed()

## Deep duplicate helper to ensure nested resources are truly decoupled
func clone() -> BaseDataResource:
	return self.duplicate(true)

## Expert Tip: Always emit_changed() when modifying custom lists or internal states
## to ensure UI components or other listeners can react to the Resource change.
func update_metadata(key: String, value: Variant) -> void:
	metadata[key] = value
	emit_changed()
