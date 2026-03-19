# chunk_limited_pathfinder.gd
extends Node
class_name ChunkLimitedPathfinder

# Chunk-Isolated AI Pathfinding
# Restricts pathfinding searches to valid navigation regions to save CPU.

func find_path_in_region(start: Vector3, end: Vector3, allowed_regions: Array[RID]) -> PackedVector3Array:
    # Pattern: Use NavigationServer3D directly for granular query control.
    var params := NavigationPathQueryParameters3D.new()
    params.start_position = start
    params.target_position = end
    
    # EXTREMELY IMPORTANT: Limits search to current/adjacent chunks only.
    params.included_regions = allowed_regions
    
    var result := NavigationPathQueryResult3D.new()
    NavigationServer3D.query_path(params, result)
    return result.path
