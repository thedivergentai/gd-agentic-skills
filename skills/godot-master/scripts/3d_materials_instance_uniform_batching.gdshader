# Instance Uniform Shader Batching
shader_type spatial;

## Expert level batching trick: One material shared by 10,000 meshes,
## yet each mesh has a unique color or damage state.

instance uniform vec4 instance_color : source_color = vec4(1.0);
instance uniform float health_ratio = 1.0;

void fragment() {
    // Combine shared base albedo with per-instance team color
    ALBEDO = instance_color.rgb * health_ratio;
    
    # Architecture Tip: Use set_instance_shader_parameter() in script 
    # to modify these without triggering a material duplication!
}
