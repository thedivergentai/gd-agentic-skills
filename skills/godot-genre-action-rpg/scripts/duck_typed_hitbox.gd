# duck_typed_hitbox.gd
extends Area3D
class_name DuckTypedHitbox

# Duck-Typing Hitboxes for Loose Coupling
# Processes combat hits without requiring specific target class references.

@export var base_damage: float = 10.0

func _on_body_entered(body: Node3D) -> void:
    # Pattern: Check for method existence to support destructibles, actors, and props.
    if body.has_method(&"take_damage"):
        # We can pass dictionaries for complex RPG data (element, knockback).
        body.take_damage({
            "amount": base_damage,
            "source": get_parent(),
            "element": &"physical"
        })
