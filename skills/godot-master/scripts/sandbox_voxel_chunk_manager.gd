# godot-master/scripts/sandbox_voxel_chunk_manager.gd
extends Node3D

## Voxel Chunk Manager Expert Pattern
## Manages chunked rendering using MultiMeshInstance3D for optimization.

@export var chunk_size: Vector3i = Vector3i(16, 16, 16)
@export var voxel_mesh: Mesh

var _chunks: Dictionary = {} # Dictionary of Vector3i -> MultiMeshInstance3D

func set_voxel(world_pos: Vector3i, type: int) -> void:
    var chunk_coord = Vector3i(
        floor(float(world_pos.x) / chunk_size.x),
        floor(float(world_pos.y) / chunk_size.y),
        floor(float(world_pos.z) / chunk_size.z)
    )
    
    var local_pos = world_pos - (chunk_coord * chunk_size)
    _update_chunk(chunk_coord, local_pos, type)

func _update_chunk(coord: Vector3i, local_pos: Vector3i, type: int) -> void:
    if not _chunks.has(coord):
        _create_chunk(coord)
        
    var mm = _chunks[coord]
    # In an expert implementation, we would manage a typed buffer here.
    # For the pattern, we show the transformation logic.
    var index = _get_index(local_pos)
    var transform = Transform3D(Basis(), Vector3(local_pos))
    
    if type > 0:
        mm.multimesh.set_instance_transform(index, transform)
        # mm.multimesh.set_instance_custom_data(index, Color(type, 0, 0))
    else:
        # Hide the voxel by moving it out of view or scaling to 0
        mm.multimesh.set_instance_transform(index, Transform3D(Basis().scaled(Vector3.ZERO), Vector3.ZERO))

func _create_chunk(coord: Vector3i) -> void:
    var mm = MultiMeshInstance3D.new()
    mm.multimesh = MultiMesh.new()
    mm.multimesh.transform_format = MultiMesh.TRANSFORM_3D
    mm.multimesh.use_custom_data = true
    mm.multimesh.instance_count = chunk_size.x * chunk_size.y * chunk_size.z
    mm.multimesh.mesh = voxel_mesh
    
    add_child(mm)
    mm.global_position = Vector3(coord * chunk_size)
    _chunks[coord] = mm

func _get_index(pos: Vector3i) -> int:
    return pos.x + (pos.y * chunk_size.x) + (pos.z * chunk_size.x * chunk_size.y)

## EXPERT NOTE:
## For performance, NEVER update MultiMesh instance transforms every frame.
## Only update when the voxel data changes.
## For 'genre-sandbox' games like Minecraft, use a custom MESH GENERATOR 
## (SurfaceTool) to create an optimized "Greedy Meshed" chunk instead of 
## individual meshes to reduce draw calls from thousands to one.
