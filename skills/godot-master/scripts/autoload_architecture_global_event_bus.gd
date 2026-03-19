# global_event_bus.gd
# Centralized signal routing to decouple systems
extends Node

# EXPERT NOTE: An Event Bus should ideally hold no state. 
# It only acts as a post office for signals.

signal level_started(id: int)
signal enemy_defeated(type: String, points: int)
signal game_paused(is_paused: bool)

func notify_enemy_killed(type: String, val: int):
	enemy_defeated.emit(type, val)
