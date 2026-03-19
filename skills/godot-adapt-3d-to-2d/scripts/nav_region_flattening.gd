# nav_region_flattening.gd
extends NavigationAgent2D
class_name NavRegionFlattener2D

## Expert 2D Pathfinding adapting 3D navigation logic.
## In 3D games, actors often navigate over varying terrain heights.
## In top-down 2D, we bake a flat NavigationPolygon but need to 
## account for simulated "Z" height obstacles (walls, platforms) 
## by manipulating navigation layers instead of Y-up vectors.

@export var is_flying: bool = false
@export var movement_speed: float = 150.0

@onready var character: CharacterBody2D = get_parent()

func _ready() -> void:
    # A top-down 2D map doesn't have true verticality.
    # To simulate flying over walls (a 3D concept), we change the 2D Nav layer.
    
    # Ground units use navigation layer 1
    # Flying units use layer 1 AND layer 2 (which spans over walls)
    if is_flying:
        set_navigation_layer_value(1, true)
        set_navigation_layer_value(2, true)
    else:
        set_navigation_layer_value(1, true)
        set_navigation_layer_value(2, false)

func seek_target(target_global_position: Vector2) -> void:
    target_position = target_global_position

func _physics_process(delta: float) -> void:
    if is_navigation_finished():
        character.velocity = Vector2.ZERO
        return
        
    var current_agent_pos = global_position 
    var next_path_pos = get_next_path_position()
    
    # Simple 2D steering that simulates reaching a specific 3D destination
    var new_velocity = current_agent_pos.direction_to(next_path_pos) * movement_speed
    
    # Optional: If your character has pseudo-3D height (jump_z_axis_sim.gd),
    # you can check if they are "above" the target here before considering them "arrived"
    
    character.velocity = new_velocity
    character.move_and_slide()
