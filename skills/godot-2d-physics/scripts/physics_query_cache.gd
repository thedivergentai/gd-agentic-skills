# skills/2d-physics/scripts/physics_query_cache.gd
extends Node2D

## Physics Query Cache (Expert Pattern)
## Caches expensive Area/Shape queries to avoid running them every frame.
## Useful for "Radar" scans or dense AI environments.

class_name PhysicsQueryCache

@export var scan_radius: float = 300.0
@export var scan_interval: float = 0.2
@export_flags_2d_physics var collision_mask: int = 1

var _cached_results: Array[Dictionary] = []
var _timer: float = 0.0

signal results_updated(results: Array[Dictionary])

func _physics_process(delta: float) -> void:
    _timer -= delta
    if _timer <= 0.0:
        _timer = scan_interval
        _perform_scan()

func _perform_scan() -> void:
    var space = get_world_2d().direct_space_state
    var query = PhysicsShapeQueryParameters2D.new()
    var shape = CircleShape2D.new()
    shape.radius = scan_radius
    
    query.shape = shape
    query.transform = global_transform
    query.collision_mask = collision_mask
    
    _cached_results = space.intersect_shape(query)
    results_updated.emit(_cached_results)

func get_results() -> Array[Dictionary]:
    return _cached_results

func get_closest() -> Node2D:
    var closest: Node2D = null
    var min_dist = INF
    
    for res in _cached_results:
        var collider = res.collider as Node2D
        if collider and collider != self:
             var d = global_position.distance_squared_to(collider.global_position)
             if d < min_dist:
                 min_dist = d
                 closest = collider
    return closest

## EXPERT USAGE:
## Attach to player/AI. Connect to 'results_updated' or poll 'get_results()'.
## Vastly cheaper than calling intersect_shape every frame.
