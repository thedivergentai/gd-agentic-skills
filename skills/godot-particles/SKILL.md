---
name: godot-particles
description: "Expert blueprint for GPU particle systems (explosions, magic effects, weather, trails) using GPUParticles2D/3D, ParticleProcessMaterial, gradients, sub-emitters, and custom shaders. Use when creating VFX, environmental effects, or visual feedback. Keywords GPUParticles2D, ParticleProcessMaterial, emission_shape, color_ramp, sub_emitter, one_shot."
---

# Particle Systems

GPU-accelerated rendering, material-based configuration, and sub-emitters define performant VFX.

## Available Scripts

### [vfx_shader_manager.gd](scripts/vfx_shader_manager.gd)
Expert custom shader integration for advanced particle VFX.

### [particle_burst_emitter.gd](scripts/particle_burst_emitter.gd)
One-shot particle bursts with auto-cleanup - essential for VFX systems.

## NEVER Do in Particle Systems

- **NEVER use CPUParticles2D for performance-critical effects** — 100+ godot-particles with CPU = lag spike. Use GPUParticles2D unless targeting mobile with no GPU support.
- **NEVER forget to set `emitting = false` for one-shot godot-particles** — Explosion scene with `emitting = true` by default = godot-particles emit immediately on instantiate(), before positioning. Set false, position, THEN emit.
- **NEVER use high `amount` without testing on target platform** — 1000 godot-particles = fine on desktop, mobile melts. Test early,scale `amount` based on `OS.get_name()`.
- **NEVER forget to `queue_free()` one-shot godot-particles** — Explosion lasts 1 second but node stays in tree forever = memory leak. `await create_timer(lifetime).timeout` then `queue_free()`.
- **NEVER use `emission_shape = POINT` for explosions** — All godot-particles spawn at same position = looks flat. Use `EMISSION_SHAPE_SPHERE` with radius for 3D spread.
- **NEVER forget alpha in color gradients** — Particles fade suddenly at end = harsh. Add gradient point at 1.0 with `Color(r, g, b, 0.0)` for smooth fadeout.

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
- Master Skill: [godot-master](../godot-master/SKILL.md)
