class_name HSMStateContext
extends RefCounted

## Expert pattern: Decoupled State Context.
## Passes dependencies through states without global singletons.

var actor: CharacterBody3D
var target: Node3D
var blackboards: Dictionary = {}

func _init(p_actor: CharacterBody3D) -> void:
	actor = p_actor

## Rule: Pass this context object to every state's 'enter' method.
