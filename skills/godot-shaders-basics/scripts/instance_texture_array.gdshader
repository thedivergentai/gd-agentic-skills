# instance_texture_array.gdshader
# Selecting unique textures in a batch using TextureArrays and Instance Uniforms [28]
shader_type spatial;

// Regular uniform array (shared by all batched instances)
uniform sampler2DArray textures_collection : source_color;

// Instance-specific index (unique per node, but maintains batching)
instance uniform int texture_variant_index = 0;

void fragment() {
	// Use the instance index to pick a layer from the array
	ALBEDO = texture(textures_collection, vec3(UV, float(texture_variant_index))).rgb;
}
