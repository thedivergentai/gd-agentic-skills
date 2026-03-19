# signal_combat_decoupler.gd
# "Signal Up, Call Down" architecture for combat
extends Node

# EXPERT NOTE: Avoid coupling UI to combat. 
# Combat nodes emit signals; UI nodes observe and react.

signal combat_logged(msg: String, type: String)

func _on_damage_dealt(target: String, amount: int):
	# UI/Log decoupled via signal
	combat_logged.emit("Hit %s for %d damage!" % [target, amount], "damage")

func _on_death():
	combat_logged.emit("Enemy defeated!", "death")
