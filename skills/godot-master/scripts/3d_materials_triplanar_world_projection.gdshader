# Triplanar World Texture Projection
shader_type spatial;

## UV-less mapping for cliffs, caves, or procedural meshes.
## Blends textures based on surface normals.

uniform sampler2D wall_texture : source_color;
uniform float triplanar_sharpness = 2.0;

void fragment() {
    vec3 blending = abs(NORMAL);
    blending /= (blending.x + blending.y + blending.z);
    blending = pow(blending, vec3(triplanar_sharpness));
    blending /= (blending.x + blending.y + blending.z);
    
    vec3 x_tex = texture(wall_texture, VERTEX.zy).rgb;
    vec3 y_tex = texture(wall_texture, VERTEX.xz).rgb;
    vec3 z_tex = texture(wall_texture, VERTEX.xy).rgb;
    
    ALBEDO = x_tex * blending.x + y_tex * blending.y + z_tex * blending.z;
}
