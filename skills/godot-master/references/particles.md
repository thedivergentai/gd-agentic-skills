---
name: godot-particles
description: "Expert blueprint for GPU particle systems (explosions, magic effects, weather, trails) using GPUParticles2D/3D, ParticleProcessMaterial, gradients, sub-emitters, and custom shaders. Use when creating VFX, environmental effects, or visual feedback. Keywords GPUParticles2D, ParticleProcessMaterial, emission_shape, color_ramp, sub_emitter, one_shot."
---

# Particle Systems

GPU-accelerated rendering, material-based configuration, and sub-emitters define performant VFX.

## Available Scripts

### [vfx_shader_manager.gd](../scripts/particles_vfx_shader_manager.gd)
Expert custom shader integration for advanced particle VFX.

### [particle_burst_emitter.gd](../scripts/particles_particle_burst_emitter.gd)
One-shot particle bursts with auto-cleanup - essential for VFX systems.

### [custom_particle_logic.gdshader](../scripts/particles_custom_particle_logic.gdshader)
Expert procedural particle movement logic. Demonstrates persistent `CUSTOM` data and `USERDATA` injection for dynamic wind/orbit effects.

### [sub_emitter_impact.gdshader](../scripts/particles_sub_emitter_impact.gdshader)
High-performance collision handling. Triggers sub-emitters (splashes/debris) using `emit_subparticle()` and `COLLISION_NORMAL`.

### [particle_attractor_opt.gd](../scripts/particles_particle_attractor_opt.gd)
Optimization pattern using `cull_mask` to isolate particle-attractor interactions, preventing global performance bottlenecks.

### [massive_swarm_multimesh.gd](../scripts/particles_massive_swarm_multimesh.gd)
Bypassing GPUParticles for millions of entities (fish, insects). Uses `set_buffer_interpolated()` for jitter-free high-count movement.

### [dynamic_userdata_modulation.gd](../scripts/particles_dynamic_userdata_modulation.gd)
Clean architectual pattern for passing runtime variables to particle shaders via `USERDATA` to preserve GPU batching.

### [local_vs_global_coords.gd](../scripts/particles_local_vs_global_coords.gd)
Expert logic for switching between localized (Auras) and global (Trails) space. Includes correct `restart()` handling for teleports.

### [smart_oneshot_recycler.gd](../scripts/particles_smart_oneshot_recycler.gd)
Robust lifecycle management using the `finished` signal and `restart()` to avoid async emission failures.

### [screenspace_weather_heightfield.gd](../scripts/particles_screenspace_weather_heightfield.gd)
Optimizing global weather (Rain/Snow) using Camera-snapped `GPUParticlesCollisionHeightField3D`.

### [particle_lod_manager.gd](../scripts/particles_particle_lod_manager.gd)
Hierarchical LOD for environmental VFX. Uses `visibility_range` and margins to cull distant torches or fires completely.

### [2d_physics_interpolation_fix.gd](../scripts/particles_2d_physics_interpolation_fix.gd)
Expert workaround for 2D particle stuttering. Switches to `CPUParticles2D` with `fract_delta` for smooth physics-parented movement.

## NEVER Do in Particle Systems

- **NEVER use `amount_ratio` to optimize performance dynamically** — It does not save GPU memory or improve processing; the full `amount` is still allocated. Change the `amount` property directly instead.
- **NEVER use CPUParticles2D for performance-critical effects on Desktop** — Use GPUParticles unless targeting low-end mobile with no GPU support. However, use CPUParticles2D if you need Physics Interpolation for smooth trails on moving bodies in 2D.
- **NEVER set `preprocess` to extremely high values** — High values (e.g., 60s) will force the GPU to simulate thousands of frames in a single render tick, potentially causing an immediate GPU crash.
- **NEVER leave `visibility_aabb` unconfigured for large systems** — Incorrect AABBs cause frustum culling errors (particles popping out) and break LOD calculations. Generate AABBs using the editor toolbar.
- **NEVER enable turbulence on Mobile/Web without testing** — 3D noise evaluation per particle is extremely heavy. Disable via Feature Tags on lower-end platforms.
- **NEVER forget to `queue_free()` one-shot particles** — Use the `finished` signal instead of an arbitrary Timer for safe lifecycle management.
- **NEVER use `local_coords = true` for trails** — Smoke or fire left behind by a projectile MUST use global space (`local_coords = false`) or the trail will follow the projectile like a stiff stick.
- **NEVER expect GPUParticles2D to interpolate correctly in Godot 4.3** — They stutter when parented to physics bodies. Use `CPUParticles2D` with `fract_delta = true` for high-speed 2D movement.
- **NEVER trigger `emitting = true` immediately after a `finished` signal** — Async GPU state delays can cause the restart to fail. Use the `restart()` method instead.
- **NEVER attempt recursion with sub-emitters** — A particle system cannot be its own sub-emitter; it will silently fail.
- **NEVER forget alpha in color gradients** — Particles that disappear instantly at the end of their lifetime look harsh; always add a gradient point at 1.0 with 0.0 alpha for a smooth exit.
- **NEVER use `EMISSION_SHAPE_POINT` for volumentric explosions** — Spawning all particles at a single point looks flat. Use a Sphere or Box shape for natural 3D spread.
- **NEVER forget to set `emitting = false` initially for one-shot VFX** — This prevents unwanted emission at the scene origin before you've had a chance to position the node via script.

---

### Basic Setup

```gdscript
# Add GPUParticles2D node
# Set Amount: 32
# Set Lifetime: 1.0
# Set One Shot: true (for explosions)
```

### Particle Material

```gdscript
# Create ParticleProcessMaterial
var material := ParticleProcessMaterial.new()

# Emission shape
material.emission_shape = ParticleProcessMaterial.EMISSION_SHAPE_SPHERE
material.emission_sphere_radius = 10.0

# Gravity
material.gravity = Vector3(0, 98, 0)

# Velocity
material.initial_velocity_min = 50.0
material.initial_velocity_max = 100.0

# Color
material.color = Color.ORANGE_RED

# Apply to godot-particles
$GPUParticles2D.process_material = material
```

## Common Effects

### Explosion

```gdscript
extends GPUParticles2D

func _ready() -> void:
    one_shot = true
    amount = 64
    lifetime = 0.8
    explosiveness = 0.9
    
    var mat := ParticleProcessMaterial.new()
    mat.emission_shape = ParticleProcessMaterial.EMISSION_SHAPE_SPHERE
    mat.emission_sphere_radius = 5.0
    mat.initial_velocity_min = 100.0
    mat.initial_velocity_max = 200.0
    mat.gravity = Vector3(0, 200, 0)
    mat.scale_min = 0.5
    mat.scale_max = 1.5
    
    process_material = mat
    emitting = true
```

### Smoke Trail

```gdscript
extends GPUParticles2D

func _ready() -> void:
    amount = 16
    lifetime = 2.0
    
    var mat := ParticleProcessMaterial.new()
    mat.direction = Vector3(0, -1, 0)
    mat.initial_velocity_min = 20.0
    mat.initial_velocity_max = 40.0
    mat.scale_min = 0.5
    mat.scale_max = 1.0
    mat.color = Color(0.5, 0.5, 0.5, 0.5)
    
    process_material = mat
```

### Sparkles/Stars

```gdscript
var mat := ParticleProcessMaterial.new()
mat.emission_shape = ParticleProcessMaterial.EMISSION_SHAPE_BOX
mat.emission_box_extents = Vector3(100, 100, 0)
mat.gravity = Vector3.ZERO
mat.angular_velocity_min = -180
mat.angular_velocity_max = 180
mat.scale_min = 0.1
mat.scale_max = 0.5

# Use star texture
$GPUParticles2D.texture = load("res://textures/star.png")
$GPUParticles2D.process_material = mat
```

## Spawn Particles on Demand

```gdscript
# player.gd
const EXPLOSION_EFFECT := preload("res://effects/explosion.tscn")

func die() -> void:
    var explosion := EXPLOSION_EFFECT.instantiate()
    get_parent().add_child(explosion)
    explosion.global_position = global_position
    explosion.emitting = true
    queue_free()
```

## 3D Particles

```gdscript
extends GPUParticles3D

func _ready() -> void:
    amount = 100
    lifetime = 3.0
    
    var mat := ParticleProcessMaterial.new()
    mat.emission_shape = ParticleProcessMaterial.EMISSION_SHAPE_BOX
    mat.emission_box_extents = Vector3(10, 0.1, 10)
    mat.direction = Vector3.UP
    mat.initial_velocity_min = 2.0
    mat.initial_velocity_max = 5.0
    mat.gravity = Vector3(0, -9.8, 0)
    
    process_material = mat
```

## Color Gradients

```gdscript
var mat := ParticleProcessMaterial.new()

# Create gradient
var gradient := Gradient.new()
gradient.add_point(0.0, Color.YELLOW)
gradient.add_point(0.5, Color.ORANGE)
gradient.add_point(1.0, Color(0.5, 0.0, 0.0, 0.0))  # Fade to transparent red

var gradient_texture := GradientTexture1D.new()
gradient_texture.gradient = gradient

mat.color_ramp = gradient_texture
```

## Sub-Emitters

```gdscript
# Particles that spawn godot-particles (fireworks)
$ParentParticles.sub_emitter = $ChildParticles.get_path()
$ParentParticles.sub_emitter_mode = GPUParticles2D.SUB_EMITTER_AT_END
```

## Best Practices

### 1. Use Texture for Shapes

```gdscript
# Add texture to godot-particles
$GPUParticles2D.texture = load("res://textures/particle.png")
```

### 2. Lifetime Management

```gdscript
# Auto-delete one-shot godot-particles
if one_shot:
    await get_tree().create_timer(lifetime).timeout
    queue_free()
```

### 3. Performance

```gdscript
# Reduce amount for mobile
if OS.get_name() == "Android":
    amount = amount / 2
```

## Reference
- [Godot Docs: Particles](https://docs.godotengine.org/en/stable/tutorials/2d/particle_systems_2d.html)


### Related
- Master Skill: [godot-master](../SKILL.md)
