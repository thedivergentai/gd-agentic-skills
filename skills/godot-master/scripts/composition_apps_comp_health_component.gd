class_name CompHealthComponent
extends Node

## Expert Decoupled Health Component.
## Acts as a data-store and logic-gate for damage.

signal health_changed(new_health: float)
signal health_depleted

@export var max_health: float = 100.0
@onready var current_health: float = max_health

func damage(amount: float) -> void:
	current_health = clamp(current_health - amount, 0, max_health)
	health_changed.emit(current_health)
	
	if current_health <= 0:
		health_depleted.emit()

## Rule: This component knows nothing about 'Player' or 'Enemies', only 'Health'.
