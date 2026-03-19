# player_ground_controller.gd
extends CharacterBody2D
class_name PlayerGroundController

# Advanced Ground Movement with Slope Physics
# Configures a CharacterBody2D for constant slope speed and floor snapping.

@export var speed: float = 300.0
var gravity: float = ProjectSettings.get_setting("physics/2d/default_gravity")

func _ready() -> void:
    # Expert Tip: Enable constant speed on slopes to prevent "launching" off peaks.
    floor_constant_speed = true
    floor_max_angle = deg_to_rad(45.0)
    floor_snap_length = 8.0 # Snap to ground even when running down slopes.

func _physics_process(delta: float) -> void:
    # NEVER multiply velocity by delta before move_and_slide().
    velocity.y += gravity * delta
    
    var input_dir := Input.get_axis(&"ui_left", &"ui_right")
    velocity.x = input_dir * speed
    
    move_and_slide()
