extends Node
class_name MobileShaderFallback

## Expert Mobile Material Optimizer
## Highly complex shaders (StandardMaterial3D with SSS, Detail textures, CLEARCOAT) 
## will crush weak mobile Adreno/Mali GPUs. This script automatically crawls the 
## SceneTree and replaces complex materials with cheap Unshaded or Vertex-Lit equivalents.

@export var optimize_on_startup: bool = true

func _ready() -> void:
    if OS.has_feature("mobile") and optimize_on_startup:
        # Start the recursive search down the tree
        _downgrade_materials(get_tree().root)

func _downgrade_materials(node: Node) -> void:
    if node is MeshInstance3D:
        _optimize_mesh_instance(node)
        
    for child in node.get_children():
        _downgrade_materials(child)

func _optimize_mesh_instance(mesh_inst: MeshInstance3D) -> void:
    for i in range(mesh_inst.get_surface_override_material_count()):
        var mat = mesh_inst.get_surface_override_material(i)
        if mat and mat is StandardMaterial3D:
            _strip_expensive_features(mat)

func _strip_expensive_features(mat: StandardMaterial3D) -> void:
    # Disable features that destroy mobile tiled renderers
    mat.clearcoat_enabled = false
    mat.subsurf_scatter_enabled = false
    mat.detail_enabled = false
    mat.distance_fade_mode = BaseMaterial3D.DISTANCE_FADE_DISABLED
    
    # If the material doesn't need to react to light dynamically, unshade it completely
    if mat.emission_enabled:
        mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
