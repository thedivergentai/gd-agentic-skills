# game_loop_waves_spawner.gd
# [GDSKILLS] godot-game-loop-waves
# EXPORT_REFERENCE: wave_spawner.gd

extends Marker3D

@export var spawn_radius: float = 0.0

func get_spawn_position() -> Vector3:
	if spawn_radius <= 0.0:
		return global_position
	
	var offset = Vector3(
		randf_range(-spawn_radius, spawn_radius),
		0,
		randf_range(-spawn_radius, spawn_radius)
	)
	return global_position + offset
