# shapecast_aoe_detection.gd
# Using ShapeCast2D for robust area-of-effect detection [Ray vs Shape]
extends ShapeCast2D

# EXPERT NOTE: RayCasts are pins. ShapeCasts are volumes. 
# Use ShapeCast2D for ground detection or melee swings to 
# prevent "skinny" collisions from missing targets.

func check_grounded() -> bool:
	# A CircleShape2D cast downwards is more stable for slopes
	# than a single RayCast2D.
	force_shapecast_update()
	return is_colliding()

func get_all_targets() -> Array:
	var hits = []
	for i in range(get_collision_count()):
		hits.append(get_collider(i))
	return hits
