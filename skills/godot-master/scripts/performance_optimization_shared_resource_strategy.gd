# shared_resource_strategy.gd
# Using Local-To-Scene vs Shared resources
extends Sprite2D

# EXPERT NOTE: By default, Resources are shared. If you change 
# a property in one instance, it changes for all. Toggle 
# "Local to Scene" for unique instances or use .duplicate() 
# for performance-balanced unique states.

@export var data: Resource

func _ready():
	# If we need a unique instance for this node:
	if not data.resource_local_to_scene:
		data = data.duplicate()
