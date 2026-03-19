# sanity_shader_manager.gd
extends Node

# Shader Uniform Manipulation for Hallucinations (Psychological Horror)
# Passes runtime sanity values directly into mesh instances without material duplication.
func update_sanity_visuals(mesh: GeometryInstance3D, current_sanity: float) -> void:
    # set_instance_shader_parameter is highly optimized and avoids per-mesh material copies.
    # Note: Requires the shader to have a 'hallucination_intensity' uniform.
    var intensity = clamp(1.0 - current_sanity, 0.0, 1.0)
    mesh.set_instance_shader_parameter(&"hallucination_intensity", intensity)
