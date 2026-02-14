class_name HitboxComponent extends Area2D

@export var health_component: HealthComponent

func _ready() -> void:
    if not health_component:
        push_error("HitboxComponent requires a HealthComponent")

func damage(amount: int) -> void:
    if health_component:
        health_component.damage(amount)
