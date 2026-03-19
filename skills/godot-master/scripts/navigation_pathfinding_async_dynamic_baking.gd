# async_dynamic_baking.gd
# Multi-threaded dynamic navmesh baking for procedural geometry
extends Node3D

var nav_mesh: NavigationMesh
var source_geometry: NavigationMeshSourceGeometryData3D

func trigger_async_bake() -> void:
	nav_mesh = NavigationMesh.new()
	source_geometry = NavigationMeshSourceGeometryData3D.new()
	
	# 1. Parse SceneTree on the MAIN thread (essential for safety).
	# This identifies geometry to be baked.
	NavigationServer3D.parse_source_geometry_data(
		nav_mesh, 
		source_geometry, 
		self, 
		Callable(self, "_on_geometry_parsed")
	)

func _on_geometry_parsed() -> void:
	# 2. Bake async on a background thread to prevent UI lockups/stutters.
	NavigationServer3D.bake_from_source_geometry_data_async(
		nav_mesh, 
		source_geometry, 
		Callable(self, "_on_baking_finished")
	)

func _on_baking_finished() -> void:
	# 3. Update the NavigationRegion3D or Server RID with the new mesh.
	print("Navmesh baked successfully in background!")
	# NavigationServer3D.region_set_navigation_mesh(region_rid, nav_mesh)
