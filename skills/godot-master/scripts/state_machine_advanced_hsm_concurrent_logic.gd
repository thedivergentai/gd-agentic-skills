class_name HSMConcurrentLogic
extends Node

## Expert Orchestrator for concurrent state machines.
## Runs multiple state machines in parallel (e.g., Locomotion + Status Effects).

@onready var locomotion_sm := $LocomotionSM
@onready var status_sm := $StatusSM

func update_all(delta: float) -> void:
	locomotion_sm.physics_update(delta)
	status_sm.physics_update(delta)

## Rule: Ensure parallel machines don't conflict over the same actor properties.
