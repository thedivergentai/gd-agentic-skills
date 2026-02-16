> [!NOTE]
> **Resource Context**: This module provides expert patterns for **Shaders**. Accessed via Godot Master.

# Shader Basics

Fragment/vertex shaders, uniforms, and built-in variables define custom visual effects using Godot's Shading Language.

## Available Scripts

### [vfx_port_shader.gdshader](../scripts/shaders_basics_vfx_port_shader.gdshader)
Expert shader template with parameter validation and common effect patterns for 2D/3D.

### [shader_parameter_animator.gd](../scripts/shaders_basics_shader_parameter_animator.gd)
Runtime shader uniform animation without AnimationPlayer - for dynamic, programmatic effects.


## NEVER Do in Shaders

- **NEVER use expensive operations in `fragment()`** — Avoid `pow()`, `sqrt()`, `sin()` on every pixel if possible. Pre-calculate or use texture lookups for performance.
- **NEVER use if/else for heavy branching** — GPUs are designed for SIMD. Use `mix()`, `step()`, and `smoothstep()` for deterministic logic.
- **NEVER modify UV without bounds checking** — Use `fract()` or `clamp()` when offseting texture coordinates to prevent sampling artifacts.
- **NEVER use `TIME` without a speed factor** — `sin(TIME)` varies by framerate if not scaled. Use `TIME * speed_factor` for consistent animation.
- **NEVER forget `hint_source_color` for color uniforms** — Without it, the Inspector shows raw floats instead of a color picker.

---

## Language Types

- **canvas_item**: Used for 2D sprites, UI, and custom drawing.
- **spatial**: Used for 3D materials and mesh rendering.
- **particles**: Used for custom GPU-accelerated particle logic.
- **sky**: Used for custom environment and background rendering.

## Common 2D Patterns

### Dissolve Effect
Uses a noise texture and a `dissolve_amount` uniform to discard pixels:
```glsl
if (noise < dissolve_amount) {
    discard;
}
```

### Outline
Samples neighboring pixels to detect transparency edges and applies an outline color.

### Screen-Space Vignette
Calculates the distance from the screen center in `SCREEN_UV` to darken the corners.

## Common 3D Patterns

### Toon/Cel Shading
Stepping the `NdotL` (Normal dot Light) calculation in the `light()` function to create distinct color bands.

## Uniform Handling in GDScript
Access and modify shader parameters at runtime:
```gdscript
material.set_shader_parameter("intensity", 0.8)
var current_val = material.get_shader_parameter("intensity")
```

## Performance Tips
1. **Move logic to `vertex()`**: Vertex calculations run once per vertex, while fragment calculations run once per pixel.
2. **Use Varyings**: Pass data from the vertex shader to the fragment shader to save processing time.
3. **Minimize texture lookups**: Each `texture()` call adds overhead.

## Reference
- [Godot Docs: Shading Language](https://docs.godotengine.org/en/stable/tutorials/shaders/shader_reference/shading_language.html)
- [Godot Docs: Introduction to Shaders](https://docs.godotengine.org/en/stable/tutorials/shaders/introduction_to_shaders.html)
