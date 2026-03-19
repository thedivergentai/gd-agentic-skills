# variable_jump.gd
extends Node
class_name VariableJump

# Variable Jump Height (Early Release Cutoff)
# Cuts upward momentum if the jump button is released mid-ascent.

@export var body: CharacterBody2D
@export var min_jump_velocity: float = -200.0

func _physics_process(_delta: float) -> void:
    # Pattern: Only cut if moving UP and button just released.
    if Input.is_action_just_released(&"jump") and body.velocity.y < min_jump_velocity:
        body.velocity.y = min_jump_velocity
