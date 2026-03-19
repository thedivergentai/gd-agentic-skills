# Custom Physics Body Gravity Override
extends CharacterBody2D

## Pattern for localized gravity overrides (Space, Water, Wind).
## Bypasses global physics settings for specialized character movement.

@export var local_gravity := Vector2(0, 400)
@export var drag_factor := 0.95

func _physics_process(delta: float) -> void:
	# Ignore default project settings gravity
	velocity += local_gravity * delta
	
	# Apply fluid drag/friction
	velocity *= pow(drag_factor, delta * 60.0)
	
	move_and_slide()
