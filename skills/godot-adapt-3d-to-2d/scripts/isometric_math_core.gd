class_name IsoMath
extends RefCounted

## Expert utility for translating between 2D Cartesian and True Isometric screenspace.
## A true isometric projection uses a 2:1 ratio (width:height). 
## This is faster than manipulating Node2D transforms and works perfectly for tilemaps and entity sorting.

const ISO_RATIO = 0.5 

## Converts a 2D world position (e.g. CharacterBody2D global_position) 
## into an Isometric screen position for rendering or sprite offsets.
static func cartesian_to_iso(cart_pos: Vector2) -> Vector2:
    return Vector2(
        cart_pos.x - cart_pos.y,
        (cart_pos.x + cart_pos.y) * ISO_RATIO
    )

## Converts an Isometric screen position (e.g. mouse click) 
## back into the 2D Cartesian world position for pathfinding or logic.
static func iso_to_cartesian(iso_pos: Vector2) -> Vector2:
    return Vector2(
        (iso_pos.x / ISO_RATIO + iso_pos.y) / 2.0,
        (iso_pos.y - iso_pos.x / ISO_RATIO) / 2.0
    )

## Get the Z-index sorting value based on Cartesian Y (depth in 3D)
static func get_iso_z_index(cart_pos: Vector2) -> int:
    # We multiply by 10 to ensure granular sorting for sub-pixel precise games
    return int(cart_pos.y * 10.0)
