# resource_local_to_scene.gd
# Creating unique resource instances per node
extends Node

# EXPERT NOTE: If you modify a Resource's property at runtime, 
# it affects EVERY node using it. Turn on "Local to Scene" or 
# call duplicate() to prevent cross-contamination.

@export var stats: ItemData

func _ready():
	# Create a unique copy so our changes don't affect other entities
	stats = stats.duplicate()
	stats.base_value += 5 # Safe modification
