# kinematic_3d_stairs_logic.gd
# Advanced stair-climbing/snapping for CharacterBody3D [Stair Logic]
extends CharacterBody3D

@export var max_stair_height: float = 0.5
@onready var stair_ray: RayCast3D = $StairRay

func _physics_process(_delta: float) -> void:
	# Custom stair-climbing is often smoother than move_and_slide's 
	# default floor_snap_length for fast characters.
	
	if is_on_floor() and velocity.length() > 0:
		if stair_ray.is_colliding():
			var hit_point = stair_ray.get_collision_point()
			var height = hit_point.y - global_position.y
			
			if height > 0 and height <= max_stair_height:
				global_position.y += height
				# Correct for the vertical jump
				# velocity.y = 0
