> [!NOTE]
> **Resource Context**: This module provides expert patterns for **Particle Systems**. Accessed via Godot Master.

# Particle Systems

GPU-accelerated rendering, material-based configuration, and sub-emitters define performant VFX.

## Available Scripts

### [vfx_shader_manager.gd](../scripts/particles_vfx_shader_manager.gd)
Expert custom shader integration for advanced particle VFX.

### [particle_burst_emitter.gd](../scripts/particles_particle_burst_emitter.gd)
One-shot particle bursts with auto-cleanup - essential for VFX systems.


## NEVER Do in Particle Systems

- **NEVER use CPUParticles2D for performance-critical effects** — Use GPUParticles unless targeting platforms with limited GPU support.
- **NEVER forget to set `emitting = false` for one-shot particles** — Position the emitter before setting `emitting = true` to avoid spawn-at-origin glitches.
- **NEVER forget to `queue_free()` one-shot particles** — Use a timer or the `finished` signal to clean up transient emitters.
- **NEVER use low alpha transitions at the end of a gradient** — Sudden disappearance looks harsh; always fade to `alpha = 0`.

---

## GPU Particles Basics
Use `ParticleProcessMaterial` to define the behavior (gravity, velocity, color, scale) of your particles.

```gdscript
var mat := ParticleProcessMaterial.new()
mat.emission_shape = ParticleProcessMaterial.EMISSION_SHAPE_SPHERE
mat.initial_velocity_min = 50.0
mat.initial_velocity_max = 100.0
$GPUParticles2D.process_material = mat
```

## Color Gradients
Use `Gradient` and `GradientTexture1D` to change particle color over their lifetime (e.g., from fire-red to smoke-gray to transparent).

## Sub-Emitters
Create complex effects like fireworks or exploding trails by using sub-emitters that fire when parent particles are born, die, or collide.

## Auto-Cleanup Pattern
For one-shot effects, ensure the node is freed after it finishes:
```gdscript
func _ready() -> void:
    emitting = true
    await finished # Signal fired when all particles finish
    queue_free()
```

## Reference
- [Godot Docs: Particles](https://docs.godotengine.org/en/stable/tutorials/2d/particle_systems_2d.html)
