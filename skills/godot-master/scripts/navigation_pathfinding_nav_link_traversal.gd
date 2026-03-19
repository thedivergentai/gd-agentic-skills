# nav_link_traversal.gd
# Advanced handling of NavigationLink3D for jumps/teleports
extends CharacterBody3D

@onready var agent: NavigationAgent3D = $NavigationAgent3D

func _physics_process(delta: float) -> void:
	if agent.is_navigation_finished(): return
	
	# Check if we are currently traversing a NavigationLink
	if agent.is_on_navigation_link():
		var link_data = agent.get_current_navigation_path_metadata()
		# Logic to detect link type and trigger jump/animation
		_handle_link_traversal(link_data)
	else:
		_standard_movement()

func _handle_link_traversal(metadata: Dictionary) -> void:
	# Path metadata allows you to know IF the current edge is a link.
	# You must manually move the agent from start to end of link.
	var next_point = agent.get_next_path_position()
	# Trigger Jump/Teleport logic here...
	pass

func _standard_movement() -> void:
	var next_pos = agent.get_next_path_position()
	velocity = global_position.direction_to(next_pos) * 5.0
	move_and_slide()
