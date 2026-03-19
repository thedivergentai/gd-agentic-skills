# High-Performance GPU Wind Sway
shader_type spatial;

## Expert level vertex sway. No bone overhead.
## Uses vertex colors (REd channel) as depth weight for foliage.

render_mode depth_prepass_alpha, cull_disabled, world_vertex_coords;

uniform sampler2D texture_albedo : source_color;
uniform float sway_speed = 1.0;
uniform float sway_strength = 0.05;

void vertex() {
    // Weight derived from vertex painting
    float weight = COLOR.r;
    float time_offset = TIME * sway_speed + VERTEX.x + VERTEX.z;
    
    VERTEX.x += sin(time_offset) * sway_strength * weight;
    VERTEX.z += cos(time_offset) * sway_strength * weight;
}

void fragment() {
    vec4 albedo_tex = texture(texture_albedo, UV);
    ALBEDO = albedo_tex.rgb;
    ALPHA = albedo_tex.a;
    ALPHA_SCISSOR_THRESHOLD = 0.5;
}
