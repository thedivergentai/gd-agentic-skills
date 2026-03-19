# combat_event_bus.gd
# Centralized bus for decoupled global combat events
extends Node

# EXPERT NOTE: A global bus (Autoload) is great for events 
# like "AnyEnemyDied" that multiple diverse systems observe.

signal player_spawned(player: Node2D)
signal enemy_defeated(experience: int)
signal boss_phase_changed(phase_id: int)

func notify_enemy_death(xp: int):
	enemy_defeated.emit(xp)
