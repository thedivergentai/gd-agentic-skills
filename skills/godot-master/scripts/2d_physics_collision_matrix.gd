# Collision Bitmask Helper
extends Node

## Managing bitmasks logically instead of hardcoding integers.
## Use constants and shift operators to keep complex faction systems readable.

enum Faction { NONE = 0, PLAYER = 1, ENEMY = 2, PROJECTILE = 3, WORLD = 4 }

func setup_actor_collision(node: CollisionObject2D, faction: Faction) -> void:
    # Clear current layers and masks
    node.collision_layer = 0
    node.collision_mask = 0
    
    # Set layer (What am I?)
    node.set_collision_layer_value(faction, true)
    
    # Set mask (What do I hit?)
    match faction:
        Faction.PLAYER:
            node.set_collision_mask_value(Faction.ENEMY, true)
            node.set_collision_mask_value(Faction.WORLD, true)
        Faction.PROJECTILE:
            node.set_collision_mask_value(Faction.ENEMY, true)
            node.set_collision_mask_value(Faction.PLAYER, true)
