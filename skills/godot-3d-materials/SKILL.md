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


## Reference
- Master Skill: [godot-master](../godot-master/SKILL.md)
