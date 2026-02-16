# godot-master/scripts/camera_systems_phantom_decoupling.gd
extends Node2D

## Phantom Camera Decoupling Pattern
## Separates 'Where we look' from 'What we follow'.

@export var target_node: Node2D
@export var smoothing: float = 0.1 # Weight (0 to 1)

var _logical_position: Vector2

func _physics_process(_delta: float) -> void:
    if not target_node: return
    
    # 1. Update Logical Position
    # This position can be influenced by secondary 'weight' sources (enemies, mouse, interest points)
    _logical_position = target_node.global_position
    
    # 2. Apply Logical Position to Camera (indirectly)
    # The actual Camera2D should follow this node, not the Player directly.
    global_position = global_position.lerp(_logical_position, smoothing)

## WHY THIS WAY?
## By following a 'Phantom' node instead of the Player, you can perform 
## cinematic offsets, lock the camera to an Area2D bounds, or shift focus 
## to an explosion without detaching the player's controls from their node.
