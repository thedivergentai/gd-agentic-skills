extends CSGShape3D

# Safe CSG Baking
# Because CSG mesh data updates are deferred to the end of the frame, 
# you must wait before extracting the baked meshes to avoid empty data.
func extract_optimized_mesh() -> void:
    # Wait for the engine to finish the deferred CSG boolean calculations
    await get_tree().process_frame
    
    var optimized_mesh: ArrayMesh = bake_static_mesh()
    var collision_shape: ConcavePolygonShape3D = bake_collision_shape()
    
    # You can now assign these to a standard MeshInstance3D and StaticBody3D
    # and safely queue_free() the heavy CSG node hierarchy.
