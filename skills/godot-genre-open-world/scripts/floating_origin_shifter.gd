# godot-master/scripts/open_world_floating_origin_shifter.gd
extends Node

## Floating Origin Shifter (Expert Pattern)
## Cyclically resets world origin to keep player near (0,0,0) and preserve float precision.

class_name FloatingOriginShifter

signal origin_shifted(offset: Vector3)

@export var threshold: float = 4000.0 # Setup safe buffer (limit is ~10k usually)
@export var world_root: Node3D # Parent of all world objects
@export var player: Node3D

func _physics_process(delta: float) -> void:
    if not player: return
    
    var dist = player.global_position.length()
    if dist > threshold:
        _shift_origin()

func _shift_origin() -> void:
    var shift_vector = -player.global_position
    # Keep Y if you want, usually full 3D shift is better
    shift_vector.y = 0 # Optional: Don't shift Y if you want height absolute
    
    # 1. Shift Root
    # Note: If player is child of world_root, this moves player too?
    # Strategy: Player usually SEPARATE from world content or handled carefully.
    # If using PhysicsServer directly, shift creates a warp.
    
    # Simplest Godot approach: Move everything EXCEPT player, then warp player?
    # OR: Move everything including player.
    
    print("Shifting Origin by: ", shift_vector)
    
    # Move all root level entities
    for node in get_tree().get_nodes_in_group("world_entities"):
        if node is Node3D:
            node.global_position += shift_vector
            
    # Move player
    player.global_position += shift_vector
    
    # Notify systems (e.g. Trail renderers needs clear)
    origin_shifted.emit(shift_vector)

## EXPERT USAGE:
## Group all static/dynamic world objects as "world_entities".
## Attach to autoload or persistent manager.
