# skills/3d-lighting/scripts/light_probe_manager.gd
extends Node3D

## Light Probe Manager (Expert Pattern)
## Helper to setup and bake VoxelGI or ReflectionProbes runtime (if supported).
## Mostly used for toggling GI states in settings.

class_name LightProbeManager

@export var voxel_gi: VoxelGI
@export var reflection_probe: ReflectionProbe

func set_gi_quality(high_quality: bool) -> void:
    if voxel_gi:
        if high_quality:
            voxel_gi.visible = true
            # Baking usually happens in editor, runtime baking is slow
        else:
            voxel_gi.visible = false
            
    if reflection_probe:
        if high_quality:
            reflection_probe.update_mode = ReflectionProbe.UPDATE_ALWAYS
        else:
             reflection_probe.update_mode = ReflectionProbe.UPDATE_ONCE

## EXPERT USAGE:
## Connect to Settings Menu.
