# skills/3d-world-building/code/collision_gen.gd
extends Node

## Collision Hull Generation Protocol

# --- 1. Selection Hierarchy (Performance Order) ---
# 1. Primitive Shapes (Box, Sphere, Capsule) - LIGHTEST
# 2. Convex Hull (Simplified wrapper) - MEDIUM
# 3. Concave Mesh (Tri-mesh) - HEAVIEST (Static World Only)

func configure_collision_for_mesh(node: MeshInstance3D, type: String = "box") -> void:
    match type:
        "box":
            node.create_multiple_convex_collisions() # Simplified convex
        "convex":
            node.create_convex_collision() # Pixel-perfect convex
        "static_world":
            node.create_trimesh_collision() # ONLY for non-moving world geometry

## EXPERT NOTE:
## NEVER use Trimesh (Concave) for moving objects. Physics will break or lag.
## For characters, always use a simple CapsuleShape3D.
## For level geometry, use 'create_multiple_convex_collisions' on import 
## to balance performance and accurate physics.
