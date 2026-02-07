# skills/genre-puzzle/scripts/grid_manager.gd
extends Node2D

## Grid Manager (Expert Pattern)
## Manages grid-based movement and logic (Sokoban style).
## Uses Tweens for smooth movement between grid cells.

class_name GridManager

signal object_moved(obj: Node2D, from: Vector2i, to: Vector2i)

@export var grid_size: Vector2i = Vector2i(64, 64)
@export var movement_duration: float = 0.2

var grid_objects: Dictionary = {} # Vector2i: Node2D

func register_object(obj: Node2D, grid_pos: Vector2i) -> void:
    grid_objects[grid_pos] = obj
    obj.position = _grid_to_world(grid_pos)

func try_move(obj: Node2D, direction: Vector2i) -> bool:
    var start_pos = _world_to_grid(obj.position)
    var target_pos = start_pos + direction
    
    # Check bounds (optional)
    
    # Check obstacles
    if grid_objects.has(target_pos):
        var obstacle = grid_objects[target_pos]
        # Push logic?
        if obstacle.has_method("is_pushable") and obstacle.is_pushable():
            if not try_move(obstacle, direction):
                return false # Chain blocked
        else:
            return false # Blocked by static object
            
    # Execute Move
    grid_objects.erase(start_pos)
    grid_objects[target_pos] = obj
    
    var tween = create_tween()
    tween.tween_property(obj, "position", _grid_to_world(target_pos), movement_duration)
    
    object_moved.emit(obj, start_pos, target_pos)
    return true

func _grid_to_world(grid_pos: Vector2i) -> Vector2:
    return Vector2(grid_pos) * Vector2(grid_size) + Vector2(grid_size) / 2.0

func _world_to_grid(world_pos: Vector2) -> Vector2i:
    return Vector2i((world_pos - Vector2(grid_size)/2.0) / Vector2(grid_size))

## EXPERT USAGE:
## Call register_object() in _ready().
## Connect Input to try_move().
