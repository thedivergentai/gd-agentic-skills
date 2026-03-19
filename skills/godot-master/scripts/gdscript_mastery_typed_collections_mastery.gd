# typed_collections_mastery.gd
# Using statically typed Arrays and Dictionaries for performance
extends Node

# EXPERT NOTE: Defining types allows the GDScript compiler to use 
# optimized opcodes. Use this for all performance-critical data.

var active_enemies: Array[CharacterBody2D] = []
var player_stats: Dictionary[String, float] = {
	"health": 100.0,
	"mana": 50.0,
	"speed": 10.0
}

func get_stat(stat_name: String) -> float:
	# Typed dictionary access is faster than untyped
	return player_stats.get(stat_name, 0.0)

func filter_dead_enemies() -> void:
	# Typed iterator optimization
	for enemy: CharacterBody2D in active_enemies:
		if enemy.is_queued_for_deletion():
			active_enemies.erase(enemy)
