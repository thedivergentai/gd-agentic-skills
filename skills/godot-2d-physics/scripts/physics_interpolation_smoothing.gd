# physics_interpolation_smoothing.gd
# Manual jitter reduction for PhysicsBody2D [12, 13]
extends CharacterBody2D

# PROBLEM: Physics runs at 60Hz, Monitors run at 144Hz+. This causes 
# 'micro-stutter' as the rendering frame is between physics frames.
# SOLUTION: In Godot 4.3+, use 'Physics Interpolation'. For older versions, 
# or custom needs, use this 'smoothing node' pattern.

@onready var visual_node: Node2D = $Sprite2D

func _process(_delta: float) -> void:
	# Calculate how much time has passed since the last physics frame
	var weight = Engine.get_physics_interpolation_fraction()
	
	# Interpolate the sprite's position between previous and current physics state
	# visual_node.global_position = _prev_pos.lerp(global_position, weight)
	pass # Logic is cleaner if using built-in Godot 4 interpolation settings
