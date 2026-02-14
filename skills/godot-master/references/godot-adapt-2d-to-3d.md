> [!NOTE]
> **Resource Context**: This module provides expert patterns for **Adapt: 2D to 3D**. Accessed via Godot Master.

# Adapt: 2D to 3D

Expert guidance for migrating 2D gameplay concepts into the third dimension, including "2.5D" hybrid rendering.

## Available Scripts

### [sprite_plane.gd](../scripts/godot-adapt-2d-to-3d_sprite_plane.gd)
Configures `Sprite3D` billboard behaviors and handles world-to-screen projection for placing 2D UI elements accurately over 3D objects.

### [vector_mapping.gd](../scripts/godot-adapt-2d-to-3d_vector_mapping.gd)
Utility for 2D-to-3D vector translation, specifically the "Y-to-Z" rule where 2D vertical movement (Y) maps to 3D forward/back movement (Z).


## NEVER Do

- **NEVER just replace Vector2 with Vector3(x, y, 0)** — This results in "flat" 3D. Add true Z-axis gameplay or camera rotation to justify the migration.
- **NEVER assume 2D collision layers work in 3D** — 2D and 3D physics use separate layer systems; you must re-name and re-assign your layers in Project Settings.
- **NEVER use `Camera2D` logic for `Camera3D`** — Directly copying positions causes clipping and motion sickness. Use `SpringArm3D` or sophisticated look-at smoothing.
- **NEVER forget to add light sources** — 3D space is unlit by default. Add at least one `DirectionalLight3D` and a `WorldEnvironment` to ensure visibility.

---

## Node Conversion Table

| 2D Node | 3D Equivalent | Primary Change |
|---------|---------------|----------------|
| CharacterBody2D | CharacterBody3D | Add Z movement & rotation |
| Sprite2D | Sprite3D / MeshInstance3D | Handle billboard/materials |
| TileMapLayer | GridMap | Create MeshLibrary tiles |
| Camera2D | Camera3D | Logic for 3rd/1st person |
| RayCast2D | RayCast3D | Change target to Vector3 |

## The Y-to-Z Rule
In 2D top-down, "Up" is -Y. In 3D, "Forward" is -Z. When porting movement code, ensure you map your 2D Y vector to the 3D Z axis for consistent input feel.

## Art Pipeline: Hybrid 2.5D
1. **Billboard Mode**: Set `Sprite3D.billboard` to `ENABLED` to make 2D sprites always face the camera in 3D space.
2. **Textured Quads**: Use a `MeshInstance3D` with a `QuadMesh` and `StandardMaterial3D` for static 2D elements within the 3D world.

## Performance Considerations
3D rendering is significantly more demanding than 2D. 
- Reduce draw calls by using `GridMap` for environments.
- Use LOD (Level of Detail) settings on meshes to minimize polygon count for distant objects.
- Cap shadow-casting lights to a essential minimum for the target platform.

## Reference
- [Godot Docs: 2D vs 3D](https://docs.godotengine.org/en/stable/tutorials/2d/2d_vs_3d.html)
- [Godot Docs: Spatial Node API](https://docs.godotengine.org/en/stable/classes/class_node3d.html)
