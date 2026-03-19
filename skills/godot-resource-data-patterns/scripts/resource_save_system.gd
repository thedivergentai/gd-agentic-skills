# resource_save_system.gd
# Serializing game state into .tres files
extends Node

# EXPERT NOTE: ResourceSaver can save custom Resources to disk.
# This is a very clean way to implement a save system.

func save_player_stats(stats: CharacterStats, slot: int):
	var path = "user://save_slot_%d.tres" % slot
	var err = ResourceSaver.save(stats, path)
	if err != OK:
		push_error("Failed to save stats: %d" % err)

func load_player_stats(slot: int) -> CharacterStats:
	var path = "user://save_slot_%d.tres" % slot
	if FileAccess.file_exists(path):
		return load(path) as CharacterStats
	return CharacterStats.new()
