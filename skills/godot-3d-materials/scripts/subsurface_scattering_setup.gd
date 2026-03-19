# Subsurface Scattering Configuration
extends MeshInstance3D

## PBR expert setup for wax, skin, and translucent organic materials.

func configure_organic_sss() -> void:
    var mat = StandardMaterial3D.new()
    
    # 1. Base SSS (Forward+ Renderer Required)
    mat.subsurf_scatter_enabled = true
    mat.subsurf_scatter_strength = 0.8
    
    # 2. Skin Mode optimization (Tints red for dermal scattering)
    mat.subsurf_scatter_skin_mode = true
    
    # 3. Transmittance (Light passing through thin mesh parts like ears)
    mat.subsurf_scatter_transmittance_enabled = true
    mat.subsurf_scatter_transmittance_color = Color(1.0, 0.4, 0.3)
    mat.subsurf_scatter_transmittance_depth = 0.1
    
    material_override = mat
