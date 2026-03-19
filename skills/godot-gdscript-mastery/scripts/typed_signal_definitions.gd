# typed_signal_definitions.gd
# Strict parameter enforcement for cross-module reliability
extends Node

# EXPERT NOTE: Typed signals prevent "String vs Int" mismatch bugs 
# that are hard to track in large projects.

signal damage_taken(amount: int, origin: Vector2, critical: bool)
signal level_up(new_level: int)

func take_hit(dmg: int, pos: Vector2):
	var is_crit = randf() > 0.8
	# Compiler validates these arguments during emit() call
	damage_taken.emit(dmg, pos, is_crit)
