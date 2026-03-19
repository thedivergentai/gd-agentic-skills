# persistent_character_stats.gd
# Saving and loading character progression
extends Node

@export var stats: CharacterStats # Custom Resource

func save_stats():
	ResourceSaver.save(stats, "user://player_stats.tres")

func load_stats():
	if ResourceLoader.exists("user://player_stats.tres"):
		stats = load("user://player_stats.tres")
