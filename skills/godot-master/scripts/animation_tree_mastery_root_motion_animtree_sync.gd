# root_motion_animtree_sync.gd
# CharacterBody3D synchronization with AnimationTree Root Motion [236]
extends CharacterBody3D

@onready var anim_tree: AnimationTree = $AnimationTree

func _physics_process(delta: float) -> void:
	# AnimationTree root motion is often more stable for blending 
	# than raw AnimationPlayer extraction.
	
	var root_pos = anim_tree.get_root_motion_position()
	var root_rot = anim_tree.get_root_motion_rotation()
	
	# Apply rotation first
	quaternion *= root_rot
	
	# Transform motion to world space and apply as velocity
	var world_motion = (quaternion * root_pos) / delta
	velocity.x = world_motion.x
	velocity.z = world_motion.z
	
	if not is_on_floor():
		velocity.y -= 9.8 * delta
	
	move_and_slide()
