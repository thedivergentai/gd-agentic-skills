# rts_path_query_pool.gd
extends Node3D
class_name RTSPathQueryPool

# Object-Pooled Navigation Path Queries
# Reuses query objects to prevent constant heap allocation during mass move orders.

var _query_params := NavigationPathQueryParameters3D.new()
var _query_result := NavigationPathQueryResult3D.new()

func get_optimized_path(start: Vector3, target: Vector3, layers: int = 1) -> PackedVector3Array:
    # Pattern: Configure pre-allocated query objects instead of creating new ones.
    _query_params.start_position = start
    _query_params.target_position = target
    _query_params.navigation_layers = layers
    _query_params.path_postprocessing = NavigationPathQueryParameters3D.PATH_POSTPROCESSING_CORRIDORFUNNEL
    
    var map_rid := get_world_3d().get_navigation_map()
    NavigationServer3D.query_path(map_rid, _query_params, _query_result)
    
    return _query_result.path
