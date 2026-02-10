---
name: godot-3d-lighting
description: "Expert patterns for Godot 3D lighting including DirectionalLight3D shadow cascades, OmniLight3D attenuation, SpotLight3D projectors, VoxelGI vs SDFGI, and LightmapGI baking. Use when implementing realistic 3D lighting, shadow optimization, global illumination, or light probes. Trigger keywords: DirectionalLight3D, OmniLight3D, SpotLight3D, shadow_enabled, directional_shadow_mode, directional_shadow_split, omni_range, omni_attenuation, spot_range, spot_angle, VoxelGI, SDFGI, LightmapGI, ReflectionProbe, Environment, WorldEnvironment."
---

# 3D Lighting

Expert guidance for realistic 3D lighting with shadows and global illumination.

## NEVER Do

- **NEVER use VoxelGI without setting a proper extents** — Unbound VoxelGI tanks performance. Always set `size` to tightly fit your scene.
- **NEVER enable shadows on every light** — Each shadow-casting light is expensive. Use shadows sparingly: 1-2 DirectionalLights, ~3-5 OmniLights max.
- **NEVER forget directional_shadow_mode** — Default is ORTHOGONAL. For large outdoor scenes, use PARALLEL_4_SPLITS for better shadow quality at distance.
- **NEVER use LightmapGI for fully dynamic scenes** — Lightmaps are baked. Moving geometry won't receive updated lighting. Use VoxelGI or SDFGI instead.
- **NEVER set omni_range too large** — Light attenuation is quadratic. A range of 500 affects 785,000 sq units. Keep range as small as visually acceptable.

---

## Available Scripts

> **MANDATORY**: Read the appropriate script before implementing the corresponding pattern.

### [day_night_cycle.gd](scripts/day_night_cycle.gd)
Dynamic sun position and color based on time-of-day. Handles DirectionalLight3D rotation, color temperature, and intensity curves. Use for outdoor day/night systems.

### [light_probe_manager.gd](scripts/light_probe_manager.gd)
VoxelGI and SDFGI management for global illumination setup.

### [lighting_manager.gd](scripts/lighting_manager.gd)
Dynamic light pooling and LOD. Manages light culling and shadow toggling based on camera distance. Use for performance optimization with many lights.

### [volumetric_fx.gd](scripts/volumetric_fx.gd)
Volumetric fog and god ray configuration. Runtime fog density/color adjustments and light shaft setup. Use for atmospheric effects.

---

## DirectionalLight3D (Sun/Moon)

### Shadow Cascades

```gdscript
# For outdoor scenes with camera moving from near to far
extends DirectionalLight3D

func _ready() -> void:
    shadow_enabled = true
    directional_shadow_mode = SHADOW_PARALLEL_4_SPLITS
    
    # Split distances (in meters from camera)
    directional_shadow_split_1 = 10.0   # First cascade: 0-10m
    directional_shadow_split_2 = 50.0   # Second: 10-50m
    directional_shadow_split_3 = 200.0  # Third: 50-200m
    # Fourth cascade: 200m - max shadow distance
    
    directional_shadow_max_distance = 500.0
    
    # Quality vs performance
    directional_shadow_blend_splits = true  # Smooth transitions
```

### Day/Night Cycle

```gdscript
# sun_controller.gd
extends DirectionalLight3D

@export var time_of_day := 12.0  # 0-24 hours
@export var rotation_speed := 0.1  # Hours per second

func _process(delta: float) -> void:
    time_of_day += rotation_speed * delta
    if time_of_day >= 24.0:
        time_of_day -= 24.0
    
    # Rotate sun (0° = noon, 180° = midnight)
    var angle := (time_of_day - 12.0) * 15.0  # 15° per hour
    rotation_degrees.x = -angle
    
    # Adjust intensity
    if time_of_day < 6.0 or time_of_day > 18.0:
        light_energy = 0.0  # Night
    elif time_of_day < 7.0:
        light_energy = remap(time_of_day, 6.0, 7.0, 0.0, 1.0)  # Sunrise
    elif time_of_day > 17.0:
        light_energy = remap(time_of_day, 17.0, 18.0, 1.0, 0.0)  # Sunset
    else:
        light_energy = 1.0  # Day
    
    # Color shift
    if time_of_day < 8.0 or time_of_day > 16.0:
        light_color = Color(1.0, 0.7, 0.4)  # Orange (dawn/dusk)
    else:
        light_color = Color(1.0, 1.0, 0.9)  # Neutral white
```

---

## OmniLight3D (Point Light)

### Attenuation Tuning

```gdscript
# torch.gd
extends OmniLight3D

func _ready() -> void:
    omni_range = 10.0  # Maximum reach
    omni_attenuation = 2.0  # Falloff curve (1.0 = linear, 2.0 = quadratic/realistic)
    
    # For "magical" lights, reduce attenuation
    omni_attenuation = 0.5  # Flatter falloff, reaches farther
```

### Flickering Effect

```gdscript
#  campfire.gd
extends OmniLight3D

@export var base_energy := 1.0
@export var flicker_strength := 0.3
@export var flicker_speed := 5.0

func _process(delta: float) -> void:
    var flicker := sin(Time.get_ticks_msec() * 0.001 * flicker_speed) * flicker_strength
    light_energy = base_energy + flicker
```

---

## SpotLight3D (Flashlight/Headlights)

### Setup

```gdscript
# flashlight.gd
extends SpotLight3D

func _ready() -> void:
    spot_range = 20.0
    spot_angle = 45.0  # Cone angle (degrees)
    spot_angle_attenuation = 2.0  # Edge softness
    
    shadow_enabled = true
    
    # Projector texture (optional - cookie/gobo)
    light_projector = load("res://textures/flashlight_mask.png")
```

### Follow Camera

```gdscript
# player_flashlight.gd
extends SpotLight3D

@onready var camera: Camera3D = get_viewport().get_camera_3d()

func _process(delta: float) -> void:
    if camera:
        global_transform = camera.global_transform
```

---

## Global Illumination: VoxelGI vs SDFGI

### Decision Matrix

| Feature | VoxelGI | SDFGI |
|---------|---------|-------|
| Setup | Manual bounds per room | Automatic, scene-wide |
| Dynamic objects | Fully supported | Partially supported |
| Performance | Moderate | Higher cost |
| Use case | Indoor, small-medium scenes | Large outdoor scenes |
| Godot version | 4.0+ | 4.0+ |

### VoxelGI Setup

```gdscript
# room_gi.gd - Place one VoxelGI per room/area
extends VoxelGI

func _ready() -> void:
    # Tightly fit the room
    size = Vector3(20, 10, 20)
    
    # Quality settings
    subdiv = VoxelGI.SUBDIV_128  # Higher = better quality, slower
    
    # Bake GI data
    bake()
```

### SDFGI Setup

```gdscript
# world_environment.gd
extends WorldEnvironment

func _ready() -> void:
    var env := environment
    
    # Enable SDFGI
    env.sdfgi_enabled = true
    env.sdfgi_use_occlusion = true
    env.sdfgi_read_sky_light = true
    
    # Cascades (auto-scale based on camera)
    env.sdfgi_min_cell_size = 0.2  # Detail level
    env.sdfgi_max_distance = 200.0
```

---

## LightmapGI (Baked Static Lighting)

### When to Use

- Static architecture (buildings, dungeons)
- Mobile/low-end targets
- No  dynamic geometry

### Setup

```gdscript
# Scene structure:
# - LightmapGI node
# - StaticBody3D meshes with GeometryInstance3D.gi_mode = STATIC

# lightmap_baker.gd
extends LightmapGI

func _ready() -> void:
    # Quality settings
    quality = LightmapGI.BAKE_QUALITY_HIGH
    bounces = 3  # Indirect light bounces
    
    # Bake (editor only, not runtime)
    # Click "Bake Lightmaps" button in editor
```

---

## Environment & Sky

### HDR Skybox

```gdscript
# world_env.gd
extends WorldEnvironment

func _ready() -> void:
    var env := environment
    
    env.background_mode = Environment.BG_SKY
    var sky := Sky.new()
    var sky_material := PanoramaSkyMaterial.new()
    sky_material.panorama = load("res://hdri/sky.hdr")
    sky.sky_material = sky_material
    env.sky = sky
    
    # Sky contribution to GI
    env.ambient_light_source = Environment.AMBIENT_SOURCE_SKY
    env.ambient_light_sky_contribution = 1.0
```

### Volumetric Fog

```gdscript
extends WorldEnvironment

func _ready() -> void:
    var env := environment
    
    env.volumetric_fog_enabled = true
    env.volumetric_fog_density = 0.01
    env.volumetric_fog_albedo = Color(0.9, 0.9, 1.0)  # Blueish
    env.volumetric_fog_emission = Color.BLACK
```

---

## ReflectionProbe

For localized reflections (mirrors, shiny floors):

```gdscript
# reflection_probe.gd
extends ReflectionProbe

func _ready() -> void:
    # Capture area
    size = Vector3(10, 5, 10)
    
    # Quality
    resolution = ReflectionProbe.RESOLUTION_512
    
    # Update mode
    update_mode = ReflectionProbe.UPDATE_ONCE  # Bake once
    # or UPDATE_ALWAYS for dynamic reflections (expensive)
```

---

## Performance Optimization

### Light Budgets

```gdscript
# Recommended limits:
# - DirectionalLight3D with shadows: 1-2
# - OmniLight3D with shadows: 3-5
# - SpotLight3D with shadows: 2-4
# - OmniLight3D without shadows: 20-30
# - SpotLight3D without shadows: 15-20

# Disable shadows on minor lights
@onready var candle_lights: Array = [$Candle1, $Candle2, $Candle3]

func _ready() -> void:
    for light in candle_lights:
        light.shadow_enabled = false  # Save performance
```

### Per-Light Shadow Distance

```gdscript
# Disable shadows for distant lights
extends OmniLight3D

@export var shadow_max_distance := 50.0

func _process(delta: float) -> void:
    var camera := get_viewport().get_camera_3d()
    if camera:
        var dist := global_position.distance_to(camera.global_position)
        shadow_enabled = (dist < shadow_max_distance)
```

---

## Edge Cases

### Shadows Through Floors

```gdscript
# Problem: Thin floors let shadows through
# Solution: Increase shadow bias

extends DirectionalLight3D

func _ready() -> void:
    shadow_enabled = true
    shadow_bias = 0.1  # Increase if shadows bleed through
    shadow_normal_bias = 2.0
```

### Light Leaking in Indoor Scenes

```gdscript
# Problem: VoxelGI light bleeds through walls
# Solution: Place VoxelGI nodes per-room, don't overlap

# Also: Ensure walls have proper thickness (not paper-thin)
```


## Reference
- Master Skill: [godot-master](../godot-master/SKILL.md)
