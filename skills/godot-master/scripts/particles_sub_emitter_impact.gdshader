# sub_emitter_impact.gdshader
# Triggering sub-emitters on collision for splashes or debris
shader_type particles;

void process() {
	if (COLLIDED) {
		mat4 sub_transform = TRANSFORM;
		// Offset slightly from collision point using normal
		sub_transform[3].xyz += COLLISION_NORMAL * 0.05;
		
		// Spawn sub-particles (debris/splash)
		// Only emit if sub-emitter is assigned to the material
		emit_subparticle(sub_transform, 
			REFLECTED_VELOCITY * 0.4, 
			vec4(1.0), 
			vec4(1.0), 
			FLAG_EMIT_POSITION | FLAG_EMIT_VELOCITY);
			
		// Kill parent particle on impact
		ACTIVE = false;
	}
}
