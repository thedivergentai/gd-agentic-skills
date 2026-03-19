## Subsystem Locator Pattern (Autoload: Subsystems)
## A decoupled alternative to monolithic managers.
## Allows systems to register themselves without requiring hard-coded paths.
extends Node

var _registry: Dictionary = {}

func register(id: StringName, instance: Node) -> void:
	_registry[id] = instance
	print("Subsystem Registered: ", id)

func unregister(id: StringName) -> void:
	_registry.erase(id)

func get_system(id: StringName) -> Node:
	return _registry.get(id)

## Usage Example:
## Subsystems.get_system(&"Inventory").add_item(loot)
