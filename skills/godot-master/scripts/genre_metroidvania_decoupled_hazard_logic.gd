# decoupled_hazard_logic.gd
extends Area2D
class_name DecoupledHazardLogic

# Decoupled Hazard Damage (Duck Typing Pattern)
# Interacts with colliding bodies safely without strict class requirements.

@export var damage_value: int = 15

func _on_body_entered(body: Node) -> void:
    # Safely checks if the body has a combat/health component method.
    if body.has_method(&"take_damage"):
        # Pattern: Pass damage and optional source metadata.
        body.take_damage(damage_value)
    elif body.has_method(&"on_hazard_collision"):
        body.on_hazard_collision(self)
