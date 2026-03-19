# hurt_box_component.gd
# Area-based component for dealing damage to HitBoxes
class_name HurtBoxComponent extends Area2D

# EXPERT NOTE: Hurtboxes look for HitBoxComponents specifically, 
# rather than generic physics bodies, ensuring type safety.

@export var damage: float = 10.0

func _on_area_entered(area: Area2D) -> void:
	var hitbox = area as HitBoxComponent
	if hitbox:
		hitbox.handle_hit(damage)
