class_name RevivalManager
extends Node

## Manages the player's ability to resurrect after reaching 0 Health.
## Can be configured for "Lives" (Classic) or "Charges" (Sekiro-like).

signal revival_available
signal revival_consumed(charges_remaining: int)
signal true_death

@export var max_charges: int = 1
@export var starting_charges: int = 1
@export var recharge_on_checkpoint: bool = true

var current_charges: int = 0

func _ready() -> void:
	current_charges = starting_charges

func can_revive() -> bool:
	return current_charges > 0

## Call this when the player "dies". Returns true if revival logic started.
## If false, the player is truly dead (Game Over).
func attempt_revive() -> bool:
	if current_charges > 0:
		revival_available.emit()
		# Logic usually pauses here to wait for UI input (Accept/Die)
		# For this skill, we provide the consume method to be called by UI.
		return true
	
	true_death.emit()
	return false

## Call this when the player confirms they want to use a charge.
func consume_charge() -> void:
	if current_charges > 0:
		current_charges -= 1
		revival_consumed.emit(current_charges)
		# Trigger actual resurrection logic (Health restore, I-frames) elsewhere.

func recharge(amount: int = 1) -> void:
	current_charges = min(current_charges + amount, max_charges)

func full_restore() -> void:
	current_charges = max_charges
