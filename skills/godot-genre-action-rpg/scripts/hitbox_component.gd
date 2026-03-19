# hitbox_component.gd
# Safe type-casting for combat detections
extends Area2D
class_name HitboxComponent

# EXPERT NOTE: Using 'as' keyword prevents runtime crashes 
# if a non-combat node enters the area.

func _on_area_entered(area: Area2D):
	var health = area as HealthComponent
	if health:
		health.damage(10)
