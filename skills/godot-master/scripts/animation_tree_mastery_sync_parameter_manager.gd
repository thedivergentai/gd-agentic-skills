# sync_parameter_manager.gd
# Expert management of AnimationTree parameters with guards [17]
extends AnimationTree

# EXPERT NOTE: Setting parameters every frame via set() without 
# checking equality first can cause unnecessary cache invalidation 
# on the GPU and logic artifacts.

var _internal_blend_pos: Vector2 = Vector2.ZERO

func update_movement_blend(target_pos: Vector2, lerp_weight: float = 0.1) -> void:
	# Smoothly interpolate the blend position in code BEFORE applying to the tree
	_internal_blend_pos = _internal_blend_pos.lerp(target_pos, lerp_weight)
	
	# Only update if the difference is significant
	var current = get("parameters/Movement/blend_position")
	if _internal_blend_pos.distance_to(current) > 0.001:
		set("parameters/Movement/blend_position", _internal_blend_pos)

func set_condition_guarded(condition_path: String, value: bool) -> void:
	var current = get(condition_path)
	if current != value:
		set(condition_path, value)
