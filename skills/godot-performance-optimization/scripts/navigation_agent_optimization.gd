# navigation_agent_optimization.gd
# Staggering paths for massive AI crowds
extends NavigationAgent3D

# EXPERT NOTE: Recalculating hundreds of paths per frame 
# kills performance. Stagger updates using a global counter.

static var global_update_tick: int = 0

func _process(_delta):
	global_update_tick += 1
	# Only update path every 10 frames, staggered by this agent's ID
	if (global_update_tick + get_instance_id()) % 10 == 0:
		# target_position = ...
		pass
