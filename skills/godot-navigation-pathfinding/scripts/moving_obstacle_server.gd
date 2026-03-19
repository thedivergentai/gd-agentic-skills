# moving_obstacle_server.gd
# Low-level dynamic obstacle registration (e.g. for projectiles or moving hazards)
extends Node3D

var obstacle_rid: RID

func _ready() -> void:
	obstacle_rid = NavigationServer3D.obstacle_create()
	NavigationServer3D.obstacle_set_map(obstacle_rid, get_world_3d().get_navigation_map())
	
	# Radius > 0 makes it a dynamic "pusher" for RVO agents
	NavigationServer3D.obstacle_set_radius(obstacle_rid, 2.0)
	NavigationServer3D.obstacle_set_avoidance_enabled(obstacle_rid, true)

func _physics_process(delta: float) -> void:
	# Keep the RVO simulation updated with our position
	NavigationServer3D.obstacle_set_position(obstacle_rid, global_position)

func _exit_tree() -> void:
	if obstacle_rid.is_valid():
		NavigationServer3D.free_rid(obstacle_rid)
