# field_of_view_scanner.gd
# AI visibility scanner using fan-out intersection queries
extends Node3D

@export var view_distance := 50.0
@export var view_angle := 60.0
@export var ray_count := 12

func scan_fov():
	var space_state = get_world_3d().direct_space_state
	var forward = -global_transform.basis.z
	var start_angle = -view_angle / 2.0
	var step = view_angle / (ray_count - 1)
	var targets = []
	
	for i in range(ray_count):
		var angle = deg_to_rad(start_angle + i * step)
		# Rotate forward vector around UP axis
		var dir = forward.rotated(Vector3.UP, angle)
		
		var query = PhysicsRayQueryParameters3D.create(global_position, global_position + dir * view_distance)
		query.exclude = [self.get_rid()]
		
		var hit = space_state.intersect_ray(query)
		if hit: targets.append(hit)
		
	return targets
