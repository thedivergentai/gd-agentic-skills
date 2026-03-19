class_name CompHitboxComponent
extends Area2D

## Expert Hitbox Component.
## Maps physical collision to a HealthComponent.

@export var health_component: CompHealthComponent

func _ready() -> void:
	area_entered.connect(_on_area_entered)

func _on_area_entered(area: Area2D) -> void:
	if area.has_method("get_damage_amount"):
		health_component.damage(area.get_damage_amount())

## Rule: Use '@export' to link components in the inspector, never 'get_node'.
