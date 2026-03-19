# skills/3d-lighting/code/volumetric_fx.gd
extends Node3D

## Volumetric Lighting (FogVolume) Expert Pattern
## Demonstrates depth-aware scattering without performance tanking.

func setup_optimized_fog() -> void:
    var env := get_viewport().world_3d.environment
    if not env: return
    
    # 1. Enable Global Volumetric Fog
    env.volumetric_fog_enabled = true
    env.volumetric_fog_density = 0.01 # Subtle base
    
    # 2. Localized FogVolumes
    # Use FogVolume nodes for dense areas (valley, forest) 
    # instead of increasing global density.
    var valley_fog := FogVolume.new()
    valley_fog.size = Vector3(100, 20, 100)
    valley_fog.shape = RenderingServer.FOG_VOLUME_SHAPE_BOX
    add_child(valley_fog)

## OPTIMIZATION:
## Viewport -> Rendering -> Default (Volumetric Fog) -> 'Filter'
## Set 'Use Temporal Reproduction' to TRUE to significantly reduce 
## the amount of samples needed for smooth fog.
