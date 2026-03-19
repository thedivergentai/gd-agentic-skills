# health_component.gd
# Specialized Node for managing lifespan and damage logic
class_name HealthComponent extends Node

# EXPERT NOTE: Components should be "ignorant" of their parent. 
# They emit signals up and the parent (or other components) respond.

signal health_changed(current: float, max: float)
signal health_depleted

@export var max_health: float = 100.0
@onready var current_health: float = max_health

func take_damage(amount: float) -> void:
	current_health = clamp(current_health - amount, 0, max_health)
	health_changed.emit(current_health, max_health)
	
	if current_health <= 0:
		health_depleted.emit()

func heal(amount: float) -> void:
	current_health = clamp(current_health + amount, 0, max_health)
	health_changed.emit(current_health, max_health)
