# godot-master/scripts/3d_lighting_lighting_manager.gd
extends Node

## SDFGI & Hybrid Lighting Expert Pattern
## Manages global illumination settings for optimal performance.

func configure_sdfgi_for_scene(optimization_level: String = "balanced") -> void:
    var env := get_viewport().world_3d.environment
    if not env: return
    
    env.sdfgi_enabled = true
    
    match optimization_level:
        "fast":
            env.sdfgi_cascades = 4
            env.sdfgi_min_cell_size = 0.2
            env.sdfgi_use_occlusion = false # Saves GPU
        "balanced":
            env.sdfgi_cascades = 6
            env.sdfgi_min_cell_size = 0.1
            env.sdfgi_use_occlusion = true
        "high":
            env.sdfgi_cascades = 8
            env.sdfgi_y_scale = RenderingServer.ENV_SDFGI_Y_SCALE_75_PERCENT

## HYBRID PATTERN:
## Blueprints for using LightmapGI for static environment (baked) 
## mixed with SDFGI for dynamic bounce lighting.
## 1. Set Environment Nodes to Bake Mode: 'Static'
## 2. Generate LightmapGI
## 3. Enable SDFGI but set its 'Energy' low (0.2) to fill in dynamic gaps.
