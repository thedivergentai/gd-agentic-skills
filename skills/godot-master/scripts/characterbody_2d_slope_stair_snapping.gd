# slope_stair_snapping.gd
# Advanced slope handling and stair-stepping logic [Snapping]
extends CharacterBody2D

# EXPERT NOTE: move_and_slide() in Godot 4 handles many slope cases 
# automatically if 'floor_max_angle' is set correctly. 
# However, stair-stepping requires manual 'teleport-ahead' logic.

@export var max_step_height: float = 8.0

func _physics_process(delta: float) -> void:
	# Apply normal movement
	move_and_slide()
	
	# Manual stair snapping logic if we hit a wall while moving
	if is_on_wall() and velocity.x != 0:
		# Check if there is a 'step' above the current position
		var space = get_world_2d().direct_space_state
		var query = PhysicsRayQueryParameters2D.create(
			global_position + Vector2(velocity.x * delta, -max_step_height),
			global_position + Vector2(velocity.x * delta, 0)
		)
		var result = space.intersect_ray(query)
		if result:
			# If there is a floor above us, snap to it
			global_position.y = result.position.y
