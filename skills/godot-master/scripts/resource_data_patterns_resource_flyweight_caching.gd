# resource_flyweight_caching.gd
# Optimizing memory via shared Resource instances
extends Node

# EXPERT NOTE: Godot automatically uses the Flyweight pattern for 
# Resources. Loading the same .tres file 100 times only uses 
# the memory of one instance.

func spawn_item(path: String):
	# This returns the cached reference if already loaded
	var data = load(path) as ItemData
	var item = Sprite2D.new()
	item.texture = data.icon
	add_child(item)
