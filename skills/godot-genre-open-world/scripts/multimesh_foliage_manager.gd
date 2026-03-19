# multimesh_foliage_manager.gd
extends MultiMeshInstance3D
class_name MultiMeshFoliageManager

# High-Performance Foliage Renderer
# Batch-renders thousands of static meshes (trees, rocks) in a single GPU draw call.

func setup_batch(mesh: Mesh, transforms: Array[Transform3D]) -> void:
    # Pattern: Use MultiMesh to bypass individual Node3D overhead.
    multimesh = MultiMesh.new()
    multimesh.transform_format = MultiMesh.TRANSFORM_3D
    multimesh.mesh = mesh
    
    # Pre-allocate count to prevent resizing during population.
    multimesh.instance_count = transforms.size()
    
    for i in range(transforms.size()):
        multimesh.set_instance_transform(i, transforms[i])
        
    # Pattern: Enable visibility range to cull entire batches based on distance.
    visibility_range_end = 500.0
