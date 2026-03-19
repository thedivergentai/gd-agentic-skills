# wall_slide_jump_refined.gd
# Responsive wall sliding and wall jumping mechanics
extends CharacterBody2D

@export var wall_slide_speed := 100.0
@export var wall_jump_pushback := 300.0

func _physics_process(delta: float) -> void:
	var on_wall = is_on_wall_only()
	
	if on_wall:
		# Limit fall speed while on wall
		velocity.y = min(velocity.y, wall_slide_speed)
		
		if Input.is_action_just_pressed("jump"):
			# Push away from wall and up
			var wall_normal = get_wall_normal()
			velocity.x = wall_normal.x * wall_jump_pushback
			velocity.y = -400
			
	move_and_slide()
