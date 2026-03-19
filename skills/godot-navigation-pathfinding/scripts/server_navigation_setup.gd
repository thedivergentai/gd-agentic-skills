# server_navigation_setup.gd
# Low-level NavigationServer3D usage (bypassing nodes for performance)
extends Node3D

var map_rid: RID
var region_rid: RID

func _ready() -> void:
	# Create an isolated map and set its "up" vector and active state.
	# This bypasses the overhead of the World3D default map for massive performance.
	map_rid = NavigationServer3D.map_create()
	NavigationServer3D.map_set_up(map_rid, Vector3.UP)
	NavigationServer3D.map_set_active(map_rid, true)

	# Create a region, assign it to our custom map.
	region_rid = NavigationServer3D.region_create()
	NavigationServer3D.region_set_map(region_rid, map_rid)
	
	# Apply a loaded NavigationMesh resource directly.
	# Note: In a real scenario, you'd bake this or load it.
	var navmesh: NavigationMesh = NavigationMesh.new() # Placeholder
	NavigationServer3D.region_set_navigation_mesh(region_rid, navmesh)

func _exit_tree() -> void:
	# CRITICAL: Manual RIDs must be cleaned up to prevent memory leaks!
	if region_rid.is_valid():
		NavigationServer3D.free_rid(region_rid)
	if map_rid.is_valid():
		NavigationServer3D.free_rid(map_rid)
