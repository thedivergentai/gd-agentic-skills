class_name HSMResourceStateLoader
extends Node

## Expert Data-Driven State Loader.
## Loads state configurations from .tres (Resource) files for modular AI.

@export var state_resources: Array[Resource]

func initialize_states() -> void:
	for res in state_resources:
		# Assume resource has a path to a script
		var state_node := Node.new()
		state_node.set_script(res.state_script)
		state_node.name = res.state_name
		add_child(state_node)

## Rule: Using Resources allows designers to tweak AI values without touching code.
