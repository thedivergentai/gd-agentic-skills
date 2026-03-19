# noise_terrain_displacement.gdshader
# Procedural terrain displacement using NoiseTexture2D [17]
shader_type spatial;

uniform sampler2D height_map;
uniform float height_scale = 2.0;

varying float v_height;

void vertex() {
	// Sample noise based on world position (XZ plane)
	vec2 world_uv = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xz * 0.1;
	v_height = texture(height_map, world_uv).r;
	
	// Physically displace the vertex
	VERTEX.y += v_height * height_scale;
}

void fragment() {
	// Use the height for procedural coloring (e.g. snow on peaks)
	float peak_mask = step(0.8, v_height);
	ALBEDO = mix(vec3(0.2, 0.5, 0.2), vec3(0.9, 0.9, 1.0), peak_mask);
}
