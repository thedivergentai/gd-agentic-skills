# recursive_scene_cleanup.gd
# Expert cleanup to prevent orphan nodes and leaks
extends Node

func deep_cleanup(root: Node):
	for child in root.get_children():
		deep_cleanup(child)
	
	# If node has connections, they are usually cleaned by queue_free, 
	# but manual disconnect is safer for persistent signals.
	root.queue_free()
