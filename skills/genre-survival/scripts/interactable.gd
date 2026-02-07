# skills/genre-survival/scripts/interactable.gd
extends Area3D

## Interactable Base Class (Expert Pattern)
## Standardizes interaction prompt and behavior.

class_name Interactable

@export var prompt_message: String = "Interact"
@export var one_shot: bool = false

func interact(user: Node) -> void:
    _on_interact(user)
    if one_shot:
        queue_free()

func _on_interact(user: Node) -> void:
    print("Interacted with %s by %s" % [name, user.name])
    # Override this in subclasses
    # e.g. Add item to inventory

## EXPERT USAGE:
## Extend this script (e.g. PickupItem.gd).
## Player RayCast checks for 'Interactable' class.
