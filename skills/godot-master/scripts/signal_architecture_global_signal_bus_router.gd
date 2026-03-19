# global_signal_bus_router.gd
# Centralized event routing without shared gameplay state
extends Node

# EXPERT NOTE: Use a dedicated Autoload (EventBus) for broad events 
# like achievements or global UI updates. Avoid for local scene logic.

# global_events.gd (Autoload)
signal player_leveled_up(new_level: int)
signal achievement_unlocked(id: String)
signal game_saved()

func notify_level_up(level: int):
	player_leveled_up.emit(level)
