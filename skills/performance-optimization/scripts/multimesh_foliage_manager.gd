# skills/performance-optimization/code/multimesh_foliage_manager.gd
extends MultiMeshInstance3D

## MultiMesh Foliage Manager Expert Pattern
## Efficiently renders 10,000s of objects in 1 draw call.

@export var instance_count: int = 10000
@export var area_size: float = 50.0

func _ready() -> void:
    # 1. MultiMesh Initialization
    # Expert logic: Use 'MultiMeshInterface' to batch geometry.
    multimesh = MultiMesh.new()
    multimesh.transform_format = MultiMesh.TRANSFORM_3D
    multimesh.instance_count = instance_count
    multimesh.mesh = _get_standard_grass_mesh()
    
    _populate_instances()

func _populate_instances() -> void:
    # 2. Bulk Transform Assignment
    # Professional games set all transforms at once to minimize state changes.
    for i in instance_count:
        var pos = Vector3(
            randf_range(-area_size, area_size),
            0,
            randf_range(-area_size, area_size)
        )
        var basis = Basis().rotated(Vector3.UP, randf() * PI)
        multimesh.set_instance_transform(i, Transform3D(basis, pos))

func _get_standard_grass_mesh() -> Mesh:
    # Placeholder for a simple QuadMesh with a grass texture
    return QuadMesh.new()

## EXPERT NOTE:
## Use 'Draw Call Batching': MultiMesh reduces 10,000 individual nodes 
## into a SINGLE draw call, drastically reducing CPU/GPU overhead.
## For 'performance-optimization', implement 'VisibilityNotifier' to 
## hide the entire MultiMesh node when off-screen.
## NEVER call 'get_node()' or 'find_child()' in '_process'; always 
## cache references in '@onready' or unique instance IDs.
