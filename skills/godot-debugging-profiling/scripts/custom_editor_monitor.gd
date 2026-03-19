# custom_editor_monitor.gd
# Exposing game metrics to the Editor Debugger
extends Node

# EXPERT NOTE: add_custom_monitor lets you see game-specific
# bottlenecks (AI count, active projectiles) in the Monitors tab.

func _ready():
	Performance.add_custom_monitor("Game/ActiveProjectiles", _get_projectile_count)

func _get_projectile_count() -> int:
	return get_tree().get_nodes_in_group("Projectiles").size()
