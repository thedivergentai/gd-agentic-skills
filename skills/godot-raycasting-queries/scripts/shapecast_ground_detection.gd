# shapecast_ground_detection.gd
# Using ShapeCast3D for robust footing detection
extends ShapeCast3D

# EXPERT NOTE: Raycasts are thin and can miss corners. 
# Shapecasts use a volume (Circle/Box) to detect footing reliably.

func is_on_solid_ground() -> bool:
	# Ensure the shapecast is updated even if physics frame hasn't finished
	force_shapecast_update()
	return is_colliding()

func get_ground_normal() -> Vector3:
	if is_colliding():
		# Get the normal of the first contact point
		return get_collision_normal(0)
	return Vector3.UP
