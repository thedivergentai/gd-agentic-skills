# custom_collision_slider.gd
extends CharacterBody2D
class_name CustomCollisionSlider

# Custom Collision Slide Response
# Manual calculation of sliding response for high-speed or non-standard physics.

func _physics_process(delta: float) -> void:
    # Use move_and_collide for manual control.
    var collision := move_and_collide(velocity * delta)
    if collision:
        # Expert Pattern: Manually slide along the normal to prevent sticking.
        velocity = velocity.slide(collision.get_normal())
