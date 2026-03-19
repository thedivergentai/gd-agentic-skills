# Fixed Timestep Sub-stepping Logic
extends CharacterBody2D

## For extremely fast-moving objects (bullets), standard collision fails.
## Sub-stepping manually breaks the frame into smaller physics steps.

@export var velocity_per_second: Vector2 = Vector2(5000, 0)
@export var sub_steps: int = 4

func _physics_process(delta: float) -> void:
    var step_delta = delta / sub_steps
    for i in range(sub_steps):
        var collision = move_and_collide(velocity_per_second * step_delta)
        if collision:
            _handle_collision(collision)
            break

func _handle_collision(collision: KinematicCollision2D) -> void:
    print("Impact at: ", collision.get_position())
    queue_free()
