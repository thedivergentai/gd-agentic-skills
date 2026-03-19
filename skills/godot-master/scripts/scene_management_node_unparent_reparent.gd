# node_unparent_reparent.gd
# Safely moving nodes between scene hierarchies
extends Node

# PROBLEM: Reparenting mid-frame can cause issues with 
# transform synchronization.

func reparent_node(node: Node, new_parent: Node):
	# Preserve global transform during reparenting
	var global_xform = node.global_transform if node is Node2D or node is Node3D else null
	
	node.get_parent().remove_child(node)
	new_parent.add_child(node)
	
	if global_xform:
		node.global_transform = global_xform
