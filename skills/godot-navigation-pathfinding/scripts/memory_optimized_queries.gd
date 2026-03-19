# memory_optimized_queries.gd
# Reusing Query objects to avoid memory fragmentation/allocation spikes
extends Node3D

# Instantiate objects ONCE and reuse them for all agents.
# This prevents thousands of allocations per frame in large crowd scenes.
var query_params := NavigationPathQueryParameters3D.new()
var query_result := NavigationPathQueryResult3D.new()

func get_path_optimized(start: Vector3, target: Vector3, map: RID) -> PackedVector3Array:
	query_params.map = map
	query_params.start_position = start
	query_params.target_position = target
	
	# Execute the query reusing the same result object.
	NavigationServer3D.query_path(query_params, query_result)
	return query_result.get_path()
