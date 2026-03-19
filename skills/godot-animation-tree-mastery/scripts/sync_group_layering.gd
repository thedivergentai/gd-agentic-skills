# sync_group_layering.gd
# Using Sync Groups to keep multi-layered animations aligned [292]
extends AnimationTree

# PROBLEM: Upper body 'Reload' and Lower body 'Walk' have different lengths.
# SOLUTION: Use Sync Groups to force them to share a normalized timeline (0.0 - 1.0).

func setup_reload_sync() -> void:
	# This logic usually happens in the BlendTree editor, but scriptable here:
	var root: AnimationNodeBlendTree = tree_root
	var blend_node = root.get_node("ReloadLayer")
	
	# Enable 'sync' on the Blend2 or Add2 node combining the layers
	# This ensures the secondary animation follows the primary's phase.
	# Note: In Godot 4, this is the 'sync' property on AnimationNodeSync nodes.
	pass # Logic primarily configuration-based
