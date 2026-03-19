# bullet_decal_spawner.gd
extends Node
class_name BulletDecalSpawner

# Spawning Dynamic Bullet Decals
# Correctly projects textures across uneven surfaces using the Decal node.

@export var bullet_hole_texture: Texture2D

func spawn_decal(hit_position: Vector3, hit_normal: Vector3) -> void:
    var decal := Decal.new()
    decal.texture_albedo = bullet_hole_texture
    decal.size = Vector3(0.1, 0.1, 0.1)
    
    get_tree().root.add_child(decal)
    decal.global_position = hit_position
    
    # Pattern: Align decal to surface normal.
    if hit_normal != Vector3.UP and hit_normal != Vector3.DOWN:
        decal.look_at(hit_position + hit_normal, Vector3.UP)
    elif hit_normal == Vector3.UP:
        decal.rotation_degrees.x = 90
    else:
        decal.rotation_degrees.x = -90
        
    # Optimization: Decals should have a lifespan.
    var timer := get_tree().create_timer(10.0)
    timer.timeout.connect(decal.queue_free)
