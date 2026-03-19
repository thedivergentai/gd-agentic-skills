# raycast_hit_prediction.gd
# Using RayCast2D for hitscan weapons and prediction logic
extends RayCast2D

# EXPERT NOTE: Don't rely solely on '_physics_process' update. 
# Force updates for immediate logic resolution (like rapid fire).

func fire_shot() -> void:
	# Move ray to weapon muzzle
	force_raycast_update()
	
	if is_colliding():
		var target = get_collider()
		var point = get_collision_point()
		var normal = get_collision_normal()
		
		_apply_impact_vfx(point, normal)
		if target.has_method("take_damage"):
			target.take_damage(25)

func _apply_impact_vfx(_point: Vector2, _normal: Vector2):
	pass
