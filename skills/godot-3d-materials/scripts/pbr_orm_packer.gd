# PBR ORM Texture Packer Utility
extends Resource

## Expert pattern: Combine Ambient Occlusion, Roughness, and Metallic
## into one RGB texture (ORM) to save 2 texture slots and GPU memory.

func get_orm_material(albedo: Texture, orm: Texture, normal: Texture) -> StandardMaterial3D:
    var mat = StandardMaterial3D.new()
    mat.albedo_texture = albedo
    
    # Mandatory channel mapping for ORM
    mat.orm_texture = orm # R=AO, G=Rough, B=Metal
    
    mat.normal_enabled = true
    mat.normal_texture = normal
    
    # Optimization: Use triplanar in world space for large terrain meshes
    mat.uv1_triplanar = true
    mat.uv1_world_triplanar = true
    
    return mat
