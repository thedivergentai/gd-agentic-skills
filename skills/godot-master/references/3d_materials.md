> [!NOTE]
> **Resource Context**: This module provides expert patterns for **3D Materials**. Accessed via Godot Master.

# 3D Materials

Expert guidance for PBR (Physically Based Rendering) materials and `StandardMaterial3D` in Godot.

## Available Scripts

### [material_fx.gd](../scripts/3d_materials_material_fx.gd)
Runtime material property animation for damage effects, dissolve, and texture swapping. Use for dynamic material state changes.

### [pbr_material_builder.gd](../scripts/3d_materials_pbr_material_builder.gd)
Runtime PBR material creation with ORM textures and triplanar mapping.

### [organic_material.gd](../scripts/3d_materials_organic_material.gd)
Subsurface scattering and rim lighting setup for realistic organic surfaces (skin, leaves, etc.).

### [triplanar_world.gdshader](../scripts/3d_materials_triplanar_world.gdshader)
Triplanar projection shader for terrain without UV mapping. Blends textures based on surface normals.


## NEVER Do

- **NEVER use separate metallic/roughness/AO textures** — Use ORM packing (1 RGB texture with Ambient Occlusion in Red, Roughness in Green, and Metallic in Blue) to optimize memory.
- **NEVER forget to enable `normal_enabled`** — Normal maps will not render unless this property is explicitly set to `true`.
- **NEVER use full alpha transparency for cutout materials** — Use `ALPHA_SCISSOR` or `ALPHA_HASH` for foliage/fences to avoid depth sorting issues and performance hits.
- **NEVER set metallic values between 0.0 and 1.0 without a specific reason** — Physically, surfaces are usually either fully metallic or fully dielectric.
- **NEVER use emission without HDR enabled** — Emission energy multipliers > 1.0 require HDR rendering in your Project Settings to bloom.

---

## StandardMaterial3D Workflow
1. **Albedo**: Base color or texture.
2. **Normal Map**: Surface detail. Must enable `normal_enabled`.
3. **ORM Texture**: Use the `orm_texture` slot for packed Ambient Occlusion (R), Roughness (G), and Metallic (B) maps.

## Transparency Decision Matrix

| Mode | Use Case | Performance |
|------|----------|-------------|
| **Alpha Scissor** | Foliage, mesh cutouts | High |
| **Alpha Hash** | Dithered transitions, LODs | High |
| **Alpha Blend** | Glass, water, VFX | Low |

## Advanced Spatial Features
- **Subsurface Scattering**: Simulates light penetrating and scattering inside organic objects.
- **Refraction**: For realistic glass and water distortion.
- **Anisotropy**: For brushed metal or hair (highlights depend on surface flow).
- **Clearcoat**: Extra glossy layer for car paint or polished surfaces.

## Optimization: Material Batching
Always reuse the same `StandardMaterial3D` resource across multiple `MeshInstance3D` nodes when they share identical properties. This allows Godot to batch draw calls, significantly improving performance.

## Reference
- [Godot Docs: StandardMaterial3D](https://docs.godotengine.org/en/stable/classes/class_standardmaterial3d.html)
- [Godot Docs: Physically Based Rendering](https://docs.godotengine.org/en/stable/tutorials/3d/standard_material_3d.html)
