# godot-master/scripts/3d_materials_organic_material.gd
extends MeshInstance3D

## Runtime Texture & SSS Manipulation Expert Pattern
## Demonstrates dynamic wetness and organic material tuning.

func set_wetness(value: float) -> void:
    # Efficiently update multiple instances via a shared material parameter 
    # OR per-instance via shader parameters.
    
    var mat := get_active_material(0)
    if mat is StandardMaterial3D:
        # Standard PBR properties
        mat.roughness = lerp(1.0, 0.1, value)
        mat.specular = lerp(0.5, 1.0, value)
    elif mat is ShaderMaterial:
        mat.set_shader_parameter("wetness", value)

func configure_sss(depth: float) -> void:
    # Calibrating Subsurface Scattering for skin/flesh
    var mat := get_active_material(0) as StandardMaterial3D
    if mat:
        mat.subsurf_scatter_enabled = true
        mat.subsurf_scatter_strength = depth
        mat.subsurf_scatter_skin_mode = true

## EXPERT NOTE:
## When updating parameters every frame (like rain), ensure you are caching 
## the material reference in _ready() to avoid repeated get_active_material() calls.
