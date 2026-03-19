# hit_box_component.gd
# Area-based component for intercepting damage
class_name HitBoxComponent extends Area2D

# EXPERT NOTE: Hitboxes delegate damage to a HealthComponent. 
# This decouples the collision shape from the health logic.

@export var health_component: HealthComponent

func handle_hit(damage: float) -> void:
	if health_component:
		health_component.take_damage(damage)
