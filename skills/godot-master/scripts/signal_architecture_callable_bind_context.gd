# callable_bind_context.gd
# Passing extra static data to signal callbacks
extends Node

func _ready():
	# Signal emits: (hit_by, level)
	# We bind: (weapon, damage)
	# Resulting callback receives: (hit_by, level, weapon, damage)
	$Player.hit.connect(_on_hit.bind("Legendary Sword", 50))

func _on_hit(hit_by: String, level: int, weapon: String, damage: int):
	print("Hit by %s (Lvl %d) with %s for %d" % [hit_by, level, weapon, damage])
