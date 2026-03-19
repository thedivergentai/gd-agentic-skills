# triplanar_world_mapping.gdshader
# UV-less texturing for organic procedural cliffs [26]
shader_type spatial;

uniform sampler2D wall_texture : source_color;

void fragment() {
	// Calculate blending weights based on surface normal
	vec3 blending = abs(NORMAL);
	blending /= (blending.x + blending.y + blending.z);
	
	// Project texture from 3 axes using world-space positions
	// (INV_VIEW_MATRIX * vec4(VERTEX, 1.0)) gets world space [26]
	vec3 world_v = (INV_VIEW_MATRIX * vec4(VERTEX, 1.0)).xyz;
	
	vec3 x_project = texture(wall_texture, world_v.yz).rgb;
	vec3 y_project = texture(wall_texture, world_v.xz).rgb;
	vec3 z_project = texture(wall_texture, world_v.xy).rgb;
	
	ALBEDO = x_project * blending.x + y_project * blending.y + z_project * blending.z;
}
