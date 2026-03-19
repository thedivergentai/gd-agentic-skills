# spring_lerp_camera_3d.gd
# Advanced 3D camera follow using Spring interpolation [169]
extends Camera3D

@export var target: Node3D
@export var offset: Vector3 = Vector3(0, 5, 10)
@export var spring_stiffness: float = 15.0

func _physics_process(delta: float) -> void:
	if not target: return
	
	var target_pos = target.global_position + offset
	
	# Spring-based follow prevents the 'elastic' feel of simple lerp 
	# and reduces visual stutter at high speeds.
	global_position = global_position.lerp(target_pos, delta * spring_stiffness)
	
	look_at(target.global_position)
