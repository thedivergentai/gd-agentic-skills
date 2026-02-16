> [!NOTE]
> **Resource Context**: This module provides expert patterns for **Adapt: 3D to 2D**. Accessed via Godot Master.

# Adapt: 3D to 2D

Expert guidance for simplifying 3D games into 2D (or 2.5D) patterns.

## Available Scripts

### [ortho_simulation.gd](../scripts/adapt_3d_2d_ortho_simulation.gd)
Simulates 3D Z-axis height in 2D top-down games. Handles vertical velocity, gravity, sprite offset, and shadow scaling.

### [projection_utils.gd](../scripts/adapt_3d_2d_projection_utils.gd)
Projects 3D world positions to 2D screen space for UI elements like nameplates and targeting reticles.


## NEVER Do

- **NEVER remove the Z-axis without gameplay compensation** — 3D to 2D reduction loses spatial depth; replace it with layers, jump height variations, or other mechanics.
- **NEVER use orthographic Camera3D as a "2D mode" replacement** — Use the actual 2D pipeline (Camera2D) for best performance and rendering consistency.
- **NEVER assume an automatic performance gain** — Optimized 3D can outperform poorly optimized 2D (e.g., massive transparent sprite sheets with high overdraw).
- **NEVER forget to adjust gravity units** — 3D meters vs 2D pixels require significant constant scaling (e.g., 9.8 m/s² vs 980 px/s²).

---

## Dimension Reduction Strategies

### Strategy 1: True 2D (Axis Flattening)
Project the 3D plane (X, Z) directly onto the 2D plane (X, Y). Vector3(input.x, 0, input.y) becomes Vector2(input.x, input.y).

### Strategy 2: 2.5D (Layered Parallax)
Use `ParallaxBackground` and `ParallaxLayer` to simulate depth from a side-view or top-down perspective without full 3D physics.

### Strategy 3: Fixed Perspective (Isometric)
Maintain an isometric or dimetric view using 2D physics by rotating sprites and applying coordinate transforms:
```gdscript
func world_to_iso(pos: Vector2) -> Vector2:
    return Vector2(pos.x - pos.y, (pos.x + pos.y) * 0.5)
```

## Node Conversion Table

| 3D Node | 2D Equivalent | Key Difference |
|---------|---------------|----------------|
| CharacterBody3D | CharacterBody2D | Scaled gravity/velocity |
| Camera3D | Camera2D | Orthographic projection |
| Area3D | Area2D | 2D collision shapes |
| WorldEnvironment | CanvasModulate | 2D lighting logic |

## Art Pipeline: 3D to Sprite
1. **Viewport Rendering**: Use a `SubViewport` to render 3D models from fixed angles at runtime or during a build step.
2. **Pre-rendered Sprites**: Export frames from Blender or Godot at fixed increments (e.g., 8-directional sprites) for a traditional 2D feel.

## Performance Optimization
- Use `TileMapLayer` for level geometry instead of individual `Sprite2D` nodes to reduce draw calls.
- Optimize sprite sheets to maximize atlas usage and minimize texture swaps.

## Reference
- [Godot Docs: 2D vs 3D](https://docs.godotengine.org/en/stable/tutorials/2d/2d_vs_3d.html)
- [Godot Docs: Isometric Tileset](https://docs.godotengine.org/en/stable/tutorials/2d/using_tilemaps.html#isometric-tileset)
