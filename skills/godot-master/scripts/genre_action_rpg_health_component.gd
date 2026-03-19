# health_component.gd
# Entity Composition pattern for modular RPG units
extends Node
class_name HealthComponent

signal health_changed(current: int, max: int)
signal died

@export var stats: BaseStats

var current_health: int

func _ready():
	current_health = stats.max_health

func damage(amount: int):
	current_health -= amount
	health_changed.emit(current_health, stats.max_health)
	if current_health <= 0:
		died.emit()
