# skills/3d-materials/scripts/material_fx.gd
extends Node

## Material FX (Expert Pattern)
## Helper to apply damage flash or dissolve effects on StandardMaterial3D.
## Modifies material parameters temporarily.

class_name MaterialFX

static func flash_white(mesh: MeshInstance3D, duration: float = 0.1) -> void:
    var mat = mesh.material_override as StandardMaterial3D
    if not mat: 
        mat = mesh.get_active_material(0) as StandardMaterial3D
        if not mat: return
        
    # We need a unique material to not flash all enemies
    # but duplicating is expensive every hit.
    # PRE-REQUISITE: Enemies should have unique materials or MaterialOverlay.
    
    # Using 'material_overlay' is best for flash
    var flash_mat = StandardMaterial3D.new()
    flash_mat.albedo_color = Color.WHITE
    flash_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
    flash_mat.transparency = BaseMaterial3D.TRANSPARENCY_ADD
    
    mesh.material_overlay = flash_mat
    
    var tree = Engine.get_main_loop() as SceneTree
    await tree.create_timer(duration).timeout
    
    if is_instance_valid(mesh):
        mesh.material_overlay = null

## EXPERT USAGE:
## Call MaterialFX.flash_white(self) on take_damage().
