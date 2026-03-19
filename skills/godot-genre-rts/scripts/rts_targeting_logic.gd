# rts_targeting_logic.gd
extends RefCounted
class_name RTSTargetingLogic

# Fast Distance Squared Checking
# Bypasses expensive square-root math when filtering thousands of potential targets.

static func find_nearest_target(origin: Vector3, targets: Array[Node3D]) -> Node3D:
    var best_target: Node3D = null
    var min_dist_sq := INF
    
    for target in targets:
        # Pattern: Use distance_squared_to to save CPU cycles in mass loops.
        var d_sq := origin.distance_squared_to(target.global_position)
        if d_sq < min_dist_sq:
            min_dist_sq = d_sq
            best_target = target
            
    return best_target
