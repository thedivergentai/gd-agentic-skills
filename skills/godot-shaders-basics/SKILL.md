---
name: godot-shaders-basics
description: "Expert blueprint for shader programming (visual effects, post-processing, material customization) using Godot's GLSL-like shader language. Covers canvas_item (2D), spatial (3D), uniforms, built-in variables, and performance. Use when implementing custom effects OR stylized rendering. Keywords shader, GLSL, fragment, vertex, canvas_item, spatial, uniform, UV, COLOR, ALBEDO, post-processing."
---

# Shader Basics

Fragment/vertex shaders, uniforms, and built-in variables define custom visual effects.

## Available Scripts

### [vfx_port_shader.gdshader](scripts/vfx_port_shader.gdshader)
Expert shader template with parameter validation and common effect patterns.

### [shader_parameter_animator.gd](scripts/shader_parameter_animator.gd)
Runtime shader uniform animation without AnimationPlayer - for dynamic effects.

## NEVER Do in Shaders

- **NEVER use expensive operations in fragment()** — `pow()`, `sqrt()`, `sin()` on every pixel? 1920x1080 = 2M calls/frame = lag. Pre-calculate OR use texture lookups.
- **NEVER forget to normalize vectors** — `reflect(direction, normal)` without normalization? Wrong reflections + rendering artifacts. ALWAYS normalize direction vectors.
- **NEVER use if/else for branching** — GPUs hate branching (SIMD architecture). Use `mix()`, `step()`, `smoothstep()` for conditional logic.
- **NEVER modify UV without bounds check** — `UV.x += 10.0` goes outside 0-1 range? Texture sampling breaks. Use `fract()` OR `clamp()`.
- **NEVER use TIME without delta** — `COLOR.a = sin(TIME)` runs at variable speed on different framerates. Use `TIME * speed_factor` for consistent animation.
- **NEVER forget hint_source_color for colors** — `uniform vec4 tint` without hint? Inspector shows raw floats. Use `uniform vec4 tint : source_color` for color picker.

---

```gdsl
shader_type canvas_item;

void fragment() {
    // Get texture color
    vec4 tex_color = texture(TEXTURE, UV);
    
    // Tint red
    COLOR = tex_color * vec4(1.0, 0.5, 0.5, 1.0);
}
```

**Apply to Sprite:**
1. Select Sprite2D node
2. Material → New ShaderMaterial
3. Shader → New Shader
4. Paste code

## Common 2D Effects

### Dissolve Effect

```glsl
shader_type canvas_item;

uniform float dissolve_amount : hint_range(0.0, 1.0) = 0.0;
uniform sampler2D noise_texture;

void fragment() {
    vec4 tex_color = texture(TEXTURE, UV);
    float noise = texture(noise_texture, UV).r;
    
    if (noise < dissolve_amount) {
        discard;  // Make pixel transparent
    }
    
    COLOR = tex_color;
}
```

### Wave Distortion

```glsl
shader_type canvas_item;

uniform float wave_speed = 2.0;
uniform float wave_amount = 0.05;

void fragment() {
    vec2 uv = UV;
    uv.x += sin(uv.y * 10.0 + TIME * wave_speed) * wave_amount;
    
    COLOR = texture(TEXTURE, uv);
}
```

### Outline

```glsl
shader_type canvas_item;

uniform vec4 outline_color : source_color = vec4(0.0, 0.0, 0.0, 1.0);
uniform float outline_width = 2.0;

void fragment() {
    vec4 col = texture(TEXTURE, UV);
    vec2 pixel_size = TEXTURE_PIXEL_SIZE * outline_width;
    
    float alpha = col.a;
    alpha = max(alpha, texture(TEXTURE, UV + vec2(pixel_size.x, 0.0)).a);
    alpha = max(alpha, texture(TEXTURE, UV + vec2(-pixel_size.x, 0.0)).a);
    alpha = max(alpha, texture(TEXTURE, UV + vec2(0.0, pixel_size.y)).a);
    alpha = max(alpha, texture(TEXTURE, UV + vec2(0.0, -pixel_size.y)).a);
    
    COLOR = mix(outline_color, col, col.a);
    COLOR.a = alpha;
}
```

## 3D Shaders

### Basic 3D Shader

```glsl
shader_type spatial;

void fragment() {
    ALBEDO = vec3(1.0, 0.0, 0.0);  // Red material
}
```

### Toon Shading (Cel-Shading)

```glsl
shader_type spatial;

uniform vec3 base_color : source_color = vec3(1.0);
uniform int color_steps = 3;

void light() {
    float NdotL = dot(NORMAL, LIGHT);
    float stepped = floor(NdotL * float(color_steps)) / float(color_steps);
    
    DIFFUSE_LIGHT = base_color * stepped;
}
```

## Screen-Space Effects

### Vignette

```glsl
shader_type canvas_item;

uniform float vignette_strength = 0.5;

void fragment() {
    vec4 color = texture(TEXTURE, UV);
    
    // Distance from center
    vec2 center = vec2(0.5, 0.5);
    float dist = distance(UV, center);
    
    float vignette = 1.0 - dist * vignette_strength;
    
    COLOR = color * vignette;
}
```

## Uniforms (Parameters)

```glsl
// Float slider
uniform float intensity : hint_range(0.0, 1.0) = 0.5;

// Color picker
uniform vec4 tint_color : source_color = vec4(1.0);

// Texture
uniform sampler2D noise_texture;

// Access in code:
material.set_shader_parameter("intensity", 0.8)
```

## Built-in Variables

**2D (canvas_item):**
- `UV` - Texture coordinates (0-1)
- `COLOR` - Output color
- `TEXTURE` - Current texture
- `TIME` - Time since start
- `SCREEN_UV` - Screen coordinates

**3D (spatial):**
- `ALBEDO` - Base color
- `NORMAL` - Surface normal
- `ROUGHNESS` - Surface roughness
- `METALLIC` - Metallic value

## Best Practices

### 1. Use Uniforms for Tweaking

```glsl
// ✅ Good - adjustable
uniform float speed = 1.0;

void fragment() {
    COLOR.r = sin(TIME * speed);
}

// ❌ Bad - hardcoded
void fragment() {
    COLOR.r = sin(TIME * 2.5);
}
```

### 2. Optimize Performance

```glsl
// Avoid expensive operations in fragment shader
// Pre-calculate values when possible
// Use textures for complex patterns
```

### 3. Comment Shaders

```glsl
// Water wave effect
// Creates horizontal distortion based on sine wave
uniform float wave_amplitude = 0.02;
```

## Reference
- [Godot Docs: Shading Language](https://docs.godotengine.org/en/stable/tutorials/shaders/shader_reference/shading_language.html)
- [Godot Docs: Your First Shader](https://docs.godotengine.org/en/stable/tutorials/shaders/your_first_shader/your_first_2d_shader.html)


### Related
- Master Skill: [godot-master](../godot-master/SKILL.md)
