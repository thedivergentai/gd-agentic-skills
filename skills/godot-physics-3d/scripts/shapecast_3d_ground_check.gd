# shapecast_3d_ground_check.gd
# Robust ground detection for 3D characters using ShapeCast3D
extends ShapeCast3D

# EXPERT NOTE: ShapeCast3D is more reliable than RayCast3D for 
# ground detection as it handles "step up" logic and uneven 
# terrain without missing "holes" in the collision.

func _physics_process(_delta: float) -> void:
	if is_colliding():
		var normal = get_collision_normal(0)
		var angle = rad_to_deg(acos(normal.dot(Vector3.UP)))
		
		if angle < 45.0: # Max slope 45 deg
			# Character is on walkable ground
			pass
