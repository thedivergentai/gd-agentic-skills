# advanced_transition_masking.gd
# Using filters (masks) for complex layered animation separation
extends AnimationTree

# This script demonstrates how to dynamically enable/disable filters 
# for nodes like AnimationNodeAdd2 or AnimationNodeBlend2.

func enable_upper_body_mask(node_path: String, skeleton: Skeleton3D) -> void:
	# This usually refers to an AnimationNode in the BlendTree
	var root: AnimationNodeBlendTree = tree_root
	var blend_node = root.get_node(node_path)
	
	blend_node.filter_enabled = true
	
	# Enable specific bone paths (e.g. Chest and above)
	for i in range(skeleton.get_bone_count()):
		var bone_name = skeleton.get_bone_name(i)
		if "Spine" in bone_name or "Arm" in bone_name or "Head" in bone_name:
			blend_node.set_filter_path("Skeleton3D:" + bone_name, true)
