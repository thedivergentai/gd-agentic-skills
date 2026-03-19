# global_grass_flatten.gdshader
# Using GlobalShaderParameters to synchronize world interaction [23]
shader_type spatial;

// Global uniform injected project-wide via RenderingServer
global uniform vec3 player_pos;

void vertex() {
	float dist = distance(VERTEX, player_pos);
	// If player is close, squash the vertex towards the ground
	// mix() + step() is used for branchless optimization [5]
	float flatten_mask = 1.0 - step(1.5, dist);
	VERTEX.y *= mix(1.0, 0.1, flatten_mask);
}
