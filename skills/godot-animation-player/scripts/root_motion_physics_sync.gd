# root_motion_physics_sync.gd
# Expert Root Motion extraction for CharacterBody3D [155]
extends CharacterBody3D

@onready var anim_player: AnimationPlayer = $AnimationPlayer

func _physics_process(delta: float) -> void:
	# 1. Fetch the delta transform from the root bone animation
	var motion_pos = anim_player.get_root_motion_position()
	var motion_rot = anim_player.get_root_motion_rotation()
	
	# 2. Transform the animation delta into world space relative to current orientation
	var v = (quaternion * motion_pos) / delta
	
	# 3. Apply horizontal velocity while preserving vertical (gravity)
	velocity.x = v.x
	velocity.z = v.z
	
	# 4. Integrate rotation (usually only Y axis for 3D characters)
	quaternion *= motion_rot
	
	if not is_on_floor():
		velocity.y -= 9.8 * delta
		
	move_and_slide()
