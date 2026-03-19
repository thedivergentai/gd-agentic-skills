# dissolve_scissor_expert.gdshader
# Expert dissolve effect using Alpha Scissor for shadow-casting and performance
shader_type spatial;

uniform sampler2D noise_tex : source_color;
uniform float dissolve_value : hint_range(0.0, 1.0) = 0.0;
uniform vec4 edge_color : source_color = vec4(1.0, 0.5, 0.0, 1.0);
uniform float edge_thickness = 0.05;

void fragment() {
	float noise = texture(noise_tex, UV).r;
	
	// ALPHA_SCISSOR_THRESHOLD allows the depth prepass to work, 
	// which is faster than alpha blending [7]
	ALPHA = noise - dissolve_value;
	ALPHA_SCISSOR_THRESHOLD = 0.01;
	
	// Expert edge glow: use step() for branchless selection [5, 21]
	float edge_mask = step(ALPHA, edge_thickness) * step(0.001, ALPHA);
	ALBEDO = mix(ALBEDO, edge_color.rgb, edge_mask);
	EMISSION = edge_color.rgb * edge_mask * 2.0;
}
