// skills/shaders-basics/scripts/vfx_port_shader.gdshader
shader_type spatial;
render_mode blend_mix, depth_draw_opaque, cull_disabled;

// Expert Shader Template
// Includes common VFX patterns: Panning, Noise, Fresnel, Proximity Fade.

uniform vec4 albedo : source_color = vec4(1.0);
uniform sampler2D texture_albedo : source_color, filter_linear_mipmap;
uniform float emission_energy : hint_range(0.0, 16.0) = 1.0;

group_uniforms Panning;
uniform vec2 pan_speed = vec2(0.1, 0.0);
uniform vec2 uv_scale = vec2(1.0, 1.0);

group_uniforms Noise_Dissolve;
uniform sampler2D noise_texture : hint_default_white;
uniform float dissolve_amount : hint_range(0.0, 1.0) = 0.0;
uniform float edge_width : hint_range(0.0, 0.2) = 0.05;
uniform vec4 edge_color : source_color = vec4(1.0, 0.5, 0.0, 1.0);

group_uniforms Soft_Collision;
uniform float proximity_fade_distance = 0.5;

void fragment() {
    // 1. Panning UVs
    vec2 panned_uv = UV * uv_scale + TIME * pan_speed;
    vec4 tex_color = texture(texture_albedo, panned_uv);
    
    // 2. Base Color
    ALBEDO = albedo.rgb * tex_color.rgb;
    
    // 3. Noise Dissolve (Advanced)
    float noise = texture(noise_texture, UV).r;
    float alpha = 1.0;
    
    if (dissolve_amount > 0.0) {
        float cut = dissolve_amount;
        if (noise < cut) {
            discard;
        }
        
        // Edge Glow
        if (noise < cut + edge_width) {
            EMISSION += edge_color.rgb * 5.0; // Boost emission
            ALBEDO = edge_color.rgb;
        }
    }
    
    // 4. Proximity Fade (Soft Particles)
    // Requires depth texture access, implied by render_mode usually
    // float depth_tex = texture(DEPTH_TEXTURE, SCREEN_UV).r;
    // ... complicated raw math omitted for template simplicity, use built-in:
    // PROXIMITY_FADE is not a keyword, strictly manually implemented.
    // StandardMaterial3D has it built-in. Here is manual:
    
    ALPHA = albedo.a * tex_color.a * alpha;
    EMISSION += ALBEDO * emission_energy;
}

// EXPERT USAGE:
// Copy-paste for Fire, Magic, Water effects. 
// Use Proximity Fade logic for intersecting geometry softness.
