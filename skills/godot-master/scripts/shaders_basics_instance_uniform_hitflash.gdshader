# instance_uniform_hitflash.gdshader
# High-performance hit flash using instance uniforms for batching [10]
shader_type spatial;

// Instance uniforms allow thousands of nodes to have unique flash states
// while sharing a single draw call (batching).
instance uniform float hit_flash_intensity : hint_range(0.0, 1.0) = 0.0;
uniform vec3 tint_color : source_color = vec3(1.0, 1.0, 1.0);

void fragment() {
	// Blend base color with hit flash color based on the instance parameter
	ALBEDO = mix(ALBEDO, tint_color, hit_flash_intensity);
	// Optional: add a tiny bit of emission for the flash
	EMISSION = tint_color * hit_flash_intensity * 0.5;
}
