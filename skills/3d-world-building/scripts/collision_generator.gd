# skills/3d-world-building/scripts/collision_generator.gd
extends Node

## Collision Generator (Expert Pattern)
## Helper to generate collision shapes for meshes that lack them.
## Useful for imported assets or procedural geometry.

class_name CollisionGenerator

static func create_trimesh_collision(mesh_instance: MeshInstance3D) -> StaticBody3D:
    if not mesh_instance or not mesh_instance.mesh:
        return null
        
    # Check if already has child static body
    for child in mesh_instance.get_children():
        if child is StaticBody3D:
            return child as StaticBody3D
            
    mesh_instance.create_trimesh_collision()
    return mesh_instance.get_child(mesh_instance.get_child_count() - 1) as StaticBody3D

static func create_convex_collision(mesh_instance: MeshInstance3D) -> StaticBody3D:
    if not mesh_instance or not mesh_instance.mesh:
        return null

    mesh_instance.create_convex_collision()
    return mesh_instance.get_child(mesh_instance.get_child_count() - 1) as StaticBody3D

static func create_multiple_convex_collision(mesh_instance: MeshInstance3D) -> StaticBody3D:
    if not mesh_instance or not mesh_instance.mesh:
        return null
        
    mesh_instance.create_multiple_convex_collisions()
    return mesh_instance.get_child(mesh_instance.get_child_count() - 1) as StaticBody3D

## EXPERT USAGE:
## Call in _ready() or EditorScript for procedurally loaded meshes.
## Use Trimesh for static scenery, Convex for dynamic objects (if needed).
