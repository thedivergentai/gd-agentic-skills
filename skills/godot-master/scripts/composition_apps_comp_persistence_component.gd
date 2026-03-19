class_name CompPersistenceComponent
extends Node

## Expert Persistence Component.
## Automatically registers the Orchestrator for saving.

func _ready() -> void:
	add_to_group("Saveable")

func get_save_data() -> Dictionary:
	# Orchestrator calls this to collect state
	return {}

## Rule: Keep save logic in a component to easily add/remove persistence to any node.
