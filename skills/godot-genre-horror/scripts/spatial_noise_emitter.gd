# spatial_noise_emitter.gd
extends Node

# Physics-Based Noise Radius Query (Stealth/Sensing)
# Instantly detects all listening entities within a radius without relying 
# on heavy persistent collision signals or Area3D nodes.
func emit_noise(origin: Transform3D, noise_shape_rid: RID) -> void:
    var query := PhysicsShapeQueryParameters3D.new()
    query.shape_rid = noise_shape_rid
    query.transform = origin
    
    # Executes the spatial query directly in the C++ physics server for sub-millisecond response.
    var overlaps := get_world_3d().direct_space_state.intersect_shape(query)
    
    for hit in overlaps:
        # Check for modular 'listener' component or detection method.
        if hit.collider.has_method(&"investigate_noise"):
            hit.collider.investigate_noise(origin.origin)
