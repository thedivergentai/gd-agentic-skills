class_name CompLogicVisualSyncer
extends Node

## Expert pattern: Logic vs Visual Separation.
## Synchronizes a VisualComponent (VFX/Anim) to a LogicComponent.

@export var logic: Node
@export var visuals: Node

func _ready() -> void:
	if logic.has_signal("state_changed"):
		logic.state_changed.connect(_on_logic_state_changed)

func _on_logic_state_changed(new_state: String) -> void:
	if visuals.has_method("play_animation"):
		visuals.play_animation(new_state)

## Rule: Never let 'MovementLogic' know 'AnimationPlayer' exists. Use this syncer.
