shader_type canvas_item;

// Expert Ortho-to-Perspective Shader
// Apply this to a ColorRect covering your 2D game to simulate a 3D perspective warp.
// Highly useful for Mode 7 style racing games or tilting a 2D tabletop view.

uniform float vanishing_point_y : hint_range(-2.0, 2.0) = 1.0;
uniform float tilt_amount : hint_range(0.0, 5.0) = 1.0;

void fragment() {
    // Treat the screen UV as Cartesian coordinates from the center
    vec2 pos = UV * 2.0 - 1.0;
    
    // Warp the X coordinate based on its distance to the vanishing point Y
    // Objects further "up" the screen pinch inwards
    float pinch = 1.0 - (pos.y * tilt_amount);
    
    // Prevent division by zero
    pinch = max(pinch, 0.001);
    
    // Re-calculate the UV
    vec2 warped_uv = vec2((pos.x / pinch) * 0.5 + 0.5, UV.y);
    
    // Discard pixels mapped outside the screen bounds
    if (warped_uv.x < 0.0 || warped_uv.x > 1.0) {
        COLOR = vec4(0.0);
    } else {
        // Sample standard texture
        COLOR = texture(TEXTURE, warped_uv);
    }
}
