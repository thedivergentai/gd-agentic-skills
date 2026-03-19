class_name CompOrchestratorBase
extends Node

## Expert Orchestrator Pattern.
## Job: Wire components together. Math/Logic = 0%, State Management = 100%.

func _ready() -> void:
	_connect_components()

func _connect_components() -> void:
	# Pattern: Listen to signal from Component A, trigger function on Component B.
	# Example:
	# $InputComponent.action_pressed.connect($MovementComponent.apply_velocity)
	pass

## Rule: Siblings must NEVER talk directly. Always signal UP to Orchestrator.
