---
name: godot-3d-materials
description: "Expert patterns for Godot 3D PBR materials using StandardMaterial3D including albedo, metallic/roughness workflows, normal maps, ORM texture packing, transparency modes, and shader conversion. Use when creating realistic 3D surfaces, PBR workflows, or material optimization. Trigger keywords: StandardMaterial3D, BaseMaterial3D, albedo_texture, metallic, metallic_texture, roughness, roughness_texture, normal_texture, normal_enabled, orm_texture, transparency, alpha_scissor, alpha_hash, cull_mode, ShaderMaterial, shader parameters."
---

# 3D Materials

Expert guidance for PBR materials and StandardMaterial3D in Godot.

## NEVER Do

- **NEVER use separate metallic/roughness/AO textures** — Use ORM packing (1 RGB texture with Occlusion/Roughness/Metallic channels) to save texture slots and memory.
- **NEVER forget to enable normal_enabled** — Normal maps don't work unless you set `normal_enabled = true`. Silent failure is common.
- **NEVER use TRANSPARENCY_ALPHA for cutout materials** — Use TRANSPARENCY_ALPHA_SCISSOR or TRANSPARENCY_ALPHA_HASH instead. Full alpha blending is expensive and causes sorting issues.
- **NEVER set metallic = 0.5** — Materials are either metallic (1.0) or dielectric (0.0). Values between are physically incorrect except for rust/dirt transitions.
- **NEVER use emission without HDR** — Emission values > 1.0 only work with HDR rendering enabled in Project Settings.
- **NEVER use transparent materials for large environmental surfaces** — Transparent objects cannot rely on the Z-buffer for early fragment rejection, resulting in massive overdraw. If only a tiny part of a mesh is transparent, split the mesh into two surfaces: one opaque, one transparent.
- **NEVER create hundreds of slightly varied StandardMaterial3D resources if performance is dropping** — Godot minimizes GPU state changes by automatically reusing the underlying shader for materials that share the exact same configuration flags (checkboxes). Try to group your material configurations.
- **NEVER attempt to fix Z-fighting strictly by moving objects further apart** — Floating-point precision degrades over distance. To fix flickering textures, increase your Camera3D's `Near` plane property and decrease the `Far` property to compress the precision range.
- **NEVER use unique Material resources per MeshInstance3D** — This breaks draw call batching. Use 'Instance Uniforms' to vary parameters while keeping a single shared material.
- **NEVER use Decals on dynamic moving actors without a Cull Mask** — Bullet holes should not stick to the player's face as they walk over them. Mask out character layers.

---

## Available Scripts

> **MANDATORY**: Read the appropriate script before implementing the corresponding pattern.

### [material_fx.gd](scripts/material_fx.gd)
Runtime material property animation for damage effects, dissolve, and texture swapping. Use for dynamic material state changes.

### [pbr_material_builder.gd](scripts/pbr_material_builder.gd)
Runtime PBR material creation with ORM textures and triplanar mapping.

### [organic_material.gd](scripts/organic_material.gd)
Subsurface scattering and rim lighting setup for organic surfaces (skin, leaves). Use for realistic character or vegetation materials.

### [triplanar_world.gdshader](scripts/triplanar_world.gdshader)
Triplanar projection shader for terrain without UV mapping. Blends textures based on surface normals. Use for cliffs, caves, or procedural terrain.

### [pbr_orm_packer.gd](scripts/pbr_orm_packer.gd)
Expert PBR resource utility. Packs Ambient Occlusion, Roughness, and Metallic into a single ORM texture to optimize VRAM and draw calls.

### [vertex_wind_sway.gdshader](scripts/vertex_wind_sway.gdshader)
High-performance GPU-driven foliage animation. Uses vertex world coordinates and vertex color weight painting to simulate wind without skeletons.

### [triplanar_world_projection.gdshader](scripts/triplanar_world_projection.gdshader)
UV-less environment mapping. Projects textures along X/Y/Z axes for organic blending over complex rocks and terrain.

### [subsurface_scattering_setup.gd](scripts/subsurface_scattering_setup.gd)
Configuring realistic organic materials. Covers Skin Mode, Transmittance, and depth scattering settings for Forward+ rendering.

### [instance_uniform_batching.gdshader](scripts/instance_uniform_batching.gdshader)
Architecture pattern for high-speed batching. Allows 10,000 meshes to share one material while maintaining unique colors or health states via instance uniforms.

### [decal_placer_expert.gd](scripts/decal_placer_expert.gd)
Dynamic 3D decal system with cull masking and life-cycle management for impact effects.

### [transparency_sorting_fix.gd](scripts/transparency_sorting_fix.gd)
Solving visual artifacts using Alpha Hash and Depth Prepass strategies.

### [shader_state_manager.gd](scripts/shader_state_manager.gd)
Clean pattern for toggling shader-based visual states (Frozen, Burned) on multiple entities.

### [depth_precision_fix.gd](scripts/depth_precision_fix.gd)
Camera-side fix for Z-fighting and texture flickering in large-scale worlds.

### [material_batcher.gd](scripts/material_batcher.gd)
Global override system to ensure environmental meshes draw in optimized, state-locked batches.

---

## StandardMaterial3D Basics

### PBR Texture Setup

```gdscript
# Create physically-based material
var mat := StandardMaterial3D.new()

# Albedo (base color)
mat.albedo_texture = load("res://textures/wood_albedo.png")
mat.albedo_color = Color.WHITE  # Tint multiplier

# Normal map (surface detail)
mat.normal_enabled = true  # CRITICAL: Must enable first
mat.normal_texture = load("res://textures/wood_normal.png")
mat.normal_scale = 1.0  # Bump strength

# ORM Texture (R=Occlusion, G=Roughness, B=Metallic)
mat.orm_texture = load("res://textures/wood_orm.png")

# Alternative: Separate textures (less efficient)
# mat.roughness_texture = load("res://textures/wood_roughness.png")
# mat.metallic_texture = load("res://textures/wood_metallic.png")
# mat.ao_texture = load("res://textures/wood_ao.png")

# Apply to mesh
$MeshInstance3D.material_override = mat
```

---

## Metallic vs Roughness

### Metal Workflow

```gdscript
# Pure metal (steel, gold, copper)
mat.metallic = 1.0
mat.roughness = 0.2  # Polished metal
mat.albedo_color = Color(0.8, 0.8, 0.8)  # Metal tint

# Rough metal (iron, aluminum)
mat.metallic = 1.0
mat.roughness = 0.7
```

### Dielectric Workflow

```gdscript
# Non-metal (wood, plastic, stone)
mat.metallic = 0.0
mat.roughness = 0.6  # Typical for wood
mat.albedo_color = Color(0.6, 0.4, 0.2)  # Brown wood

# Glossy plastic
mat.metallic = 0.0
mat.roughness = 0.1  # Very smooth
```

### Transition Materials (Rust/Dirt)

```gdscript
# Use texture to blend metal/non-metal
mat.metallic_texture = load("res://rust_mask.png")
# White areas (1.0) = metal
# Black areas (0.0) = rust (dielectric)
```

---

## Transparency Modes

### Decision Matrix

| Mode | Use Case | Performance | Sorting Issues |
|------|----------|-------------|---------------|
| ALPHA_SCISSOR | Foliage, chain-link fence | Fast | No |
| ALPHA_HASH | Dithered fade, LOD transitions | Fast | Noisy |
| ALPHA | Glass, water, godot-particles | Slow | Yes (render order) |

### Alpha Scissor (Cutout)

```gdscript
# For leaves, grass, fences
mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA_SCISSOR
mat.alpha_scissor_threshold = 0.5  # Pixels < 0.5 alpha = discarded
mat.albedo_texture = load("res://leaf.png")  # Must  have alpha channel

# Enable backface culling for performance
mat.cull_mode = BaseMaterial3D.CULL_BACK
```

### Alpha Hash (Dithered)

```gdscript
# For smooth fade-outs without sorting issues
mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA_HASH
mat.alpha_hash_scale = 1.0  # Dither pattern scale

# Animate fade
var tween := create_tween()
tween.tween_property(mat, "albedo_color:a", 0.0, 1.0)
```

### Alpha Blend (Full Transparency)

```gdscript
# For glass, water (expensive)
mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
mat.blend_mode = BaseMaterial3D.BLEND_MODE_MIX

# Disable depth writing for correct blending
mat.depth_draw_mode = BaseMaterial3D.DEPTH_DRAW_DISABLED
mat.cull_mode = BaseMaterial3D.CULL_DISABLED  # Show both sides
```

---

## Advanced Features

### Emission (Glowing Materials)

```gdscript
mat.emission_enabled = true
mat.emission = Color(1.0, 0.5, 0.0)  # Orange glow
mat.emission_energy_multiplier = 2.0  # Brightness (HDR)
mat.emission_texture = load("res://lava_emission.png")

# Animated emission
func _process(delta: float) -> void:
    mat.emission_energy_multiplier = 1.0 + sin(Time.get_ticks_msec() * 0.005) * 0.5
```

### Rim Lighting (Fresnel)

```gdscript
mat.rim_enabled = true
mat.rim = 1.0  # Intensity
mat.rim_tint = 0.5  # How much albedo affects rim color
```

### Clearcoat (Car Paint)

```gdscript
mat.clearcoat_enabled = true
mat.clearcoat = 1.0  # Layer strength
mat.clearcoat_roughness = 0.1  # Glossy top layer
```

### Anisotropy (Brushed Metal)

```gdscript
mat.anisotropy_enabled = true
mat.anisotropy = 1.0  # Directional highlights
mat.anisotropy_flowmap = load("res://brushed_flow.png")
```

---

## Texture Channel Packing

### ORM Texture (Recommended)

```python
# External tool (GIMP, Substance, Python script):
# Combine 3 grayscale textures into 1 RGB:
# R channel = Ambient Occlusion (bright = no occlusion)
# G channel = Roughness (bright = rough)
# B channel = Metallic (bright = metal)
```

```gdscript
# In Godot:
mat.orm_texture = load("res://textures/material_orm.png")
# This replaces ao_texture, roughness_texture, and metallic_texture!
```

### Custom Packing

```gdscript
# If using custom channel assignments:
mat.roughness_texture_channel = BaseMaterial3D.TEXTURE_CHANNEL_GREEN
mat.metallic_texture_channel = BaseMaterial3D.TEXTURE_CHANNEL_BLUE
```

---

## Shader Conversion

### When to Convert to ShaderMaterial

- Need custom effects (dissolve, vertex displacement)
- StandardMaterial3D limitations hit
- Shader optimizations (remove unused features)

### Conversion Workflow

```gdscript
# 1. Create StandardMaterial3D with all settings
var std_mat := StandardMaterial3D.new()
std_mat.albedo_color = Color.RED
std_mat.metallic = 1.0
std_mat.roughness = 0.2

# 2. Convert to ShaderMaterial
var shader_mat := ShaderMaterial.new()
shader_mat.shader = load("res://custom_shader.gdshader")

# 3. Transfer parameters manually
shader_mat.set_shader_parameter("albedo", std_mat.albedo_color)
shader_mat.set_shader_parameter("metallic", std_mat.metallic)
shader_mat.set_shader_parameter("roughness", std_mat.roughness)
```

---

## Material Variants (Godot 4.0+)

### Efficient Material Reuse

```gdscript
# Base material (shared)
var base_red_metal := StandardMaterial3D.new()
base_red_metal.albedo_color = Color.RED
base_red_metal.metallic = 1.0

# Variant 1: Rough
var rough_variant := base_red_metal.duplicate()
rough_variant.roughness = 0.8

# Variant 2: Smooth
var smooth_variant := base_red_metal.duplicate()
smooth_variant.roughness = 0.1

# Note: Use resource_local_to_scene for per-instance tweaks
```

---

## Performance Optimization

### Material Batching

```gdscript
# ✅ GOOD: Reuse materials across meshes
const SHARED_STONE := preload("res://materials/stone.tres")

func _ready() -> void:
    for wall in get_tree().get_nodes_in_group("stone_walls"):
        wall.material_override = SHARED_STONE
    # All walls batched in single draw call

# ❌ BAD: Unique material per mesh
func _ready() -> void:
    for wall in get_tree().get_nodes_in_group("stone_walls"):
        var mat := StandardMaterial3D.new()  # New material!
        mat.albedo_color = Color(0.5, 0.5, 0.5)
        wall.material_override = mat
    # Each wall is separate draw call
```

### Texture Atlasing

```gdscript
# Combine multiple materials into one texture atlas
# Then use UV offsets to select regions

# material_atlas.gd
extends StandardMaterial3D

func set_atlas_region(tile_x: int, tile_y: int, tiles_per_row: int) -> void:
    var tile_size := 1.0 / tiles_per_row
    uv1_offset = Vector3(tile_x * tile_size, tile_y * tile_size, 0)
    uv1_scale = Vector3(tile_size, tile_size, 1)
```

---

## Edge Cases

### Normal Maps Not Working

```gdscript
# Problem: Forgot to enable
mat.normal_enabled = true  # REQUIRED

# Problem: Wrong texture import settings
# In Import tab: Texture → Normal Map = true
```

### Texture Seams on Models

```gdscript
# Problem: Mipmaps causing seams
# Solution: Disable mipmaps for tightly-packed UVs
# Import → Mipmaps → Generate = false
```

### Material Looks Flat

```gdscript
# Problem: Missing normal map or roughness variation
# Solution: Add normal map + roughness texture

mat.normal_enabled = true
mat.normal_texture = load("res://normal.png")
mat.roughness_texture = load("res://roughness.png")
```

---

## Common Material Presets

```gdscript
# Glass
func create_glass() -> StandardMaterial3D:
    var mat := StandardMaterial3D.new()
    mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
    mat.albedo_color = Color(1, 1, 1, 0.2)
    mat.metallic = 0.0
    mat.roughness = 0.0
    mat.refraction_enabled = true
    mat.refraction_scale = 0.05
    return mat

# Gold
func create_gold() -> StandardMaterial3D:
    var mat := StandardMaterial3D.new()
    mat.albedo_color = Color(1.0, 0.85, 0.3)
    mat.metallic = 1.0
    mat.roughness = 0.3
    return mat
```



---

## Expert Techniques & Optimizations

### 1. LOD Transitions using Pixel Dither
When utilizing Hierarchical Level of Detail (HLOD) or Visibility Ranges to fade objects out at a distance, standard alpha blending causes severe performance hits due to overlapping transparent bounds. Instead, configure the **Distance Fade** mode on your material to **Pixel Dither**. This provides a perceptually smooth fade while remaining entirely within the high-performance opaque pipeline.

### 2. Stencil Buffers (Godot 4.5+)
Use the Stencil Buffer directly in `StandardMaterial3D`. This allows you to easily render outlines or X-ray effects for objects hidden behind walls without needing to write custom shaders for basic effects.

### 3. AR Shadow Overlay Shader
If you are developing an AR game, you might want virtual shadows to appear on real-world camera feeds. Instead of standard blending, use Godot's built-in `shadow_to_opacity` render mode in a spatial shader.

```shader
shader_type spatial;
// shadow_to_opacity makes the material invisible when lit, 
// but opaque (dark) when it receives a shadow from another 3D object.
render_mode blend_mix, depth_draw_opaque, cull_back, shadow_to_opacity;

void fragment() {
    // The surface color is black; opacity will be driven by incoming shadows
    ALBEDO = vec3(0.0, 0.0, 0.0);
}
```

## Reference
- Master Skill: [godot-master](../godot-master/SKILL.md)
