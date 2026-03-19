# Optimized RayCast2D AI Detection Stack
extends Node2D

## Expert pattern: Using a shared RayCast2D to perform multiple 
## directional checks in one frame to optimize NPC vision swarms.

@onready var vision_ray: RayCast2D = $VisionRay

func scan_for_target(target: Node2D, angles: Array[float], max_range: float) -> bool:
	vision_ray.enabled = true
	vision_ray.target_position = Vector2.RIGHT * max_range
	
	for angle in angles:
		vision_ray.rotation = angle
		# MANDATORY: force_raycast_update() must be called after rotation
		# if checking multiple directions in the same physics frame.
		vision_ray.force_raycast_update()
		
		if vision_ray.is_colliding() and vision_ray.get_collider() == target:
			vision_ray.enabled = false
			return true
			
	vision_ray.enabled = false
	return false
