# mouse_pick_3d_query.gd
# Picking 3D objects accurately via screen-to-world rays
extends Camera3D

const RAY_LENGTH = 1000.0

func _physics_process(_delta: float) -> void:
	if Input.is_action_just_pressed("mouse_left"):
		var result = _perform_picking()
		if result:
			print("Selected: ", result.collider.name)

func _perform_picking() -> Dictionary:
	var space_state = get_world_3d().direct_space_state
	var mouse_pos = get_viewport().get_mouse_position()
	
	# Project ray origin and normal from screen to world
	var origin = project_ray_origin(mouse_pos)
	var end = origin + project_ray_normal(mouse_pos) * RAY_LENGTH
	
	var query = PhysicsRayQueryParameters3D.create(origin, end)
	return space_state.intersect_ray(query)
