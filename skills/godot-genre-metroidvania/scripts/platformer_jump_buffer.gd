# platformer_jump_buffer.gd
extends CharacterBody2D
class_name PlatformerJumpBuffer

# Modular Jump Buffering & Coyote Time
# Ensures responsive feel by allowing jumps slightly before landing or after falling.

const JUMP_VELOCITY := -400.0
const COYOTE_TIME_MAX := 0.15
const JUMP_BUFFER_MAX := 0.1

var _coyote_timer := 0.0
var _jump_buffer_timer := 0.0

func _unhandled_input(event: InputEvent) -> void:
    # Capture jump input outside physics tick for frame-perfect buffering.
    if event.is_action_pressed(&"jump"):
        _jump_buffer_timer = JUMP_BUFFER_MAX
        get_viewport().set_input_as_handled()

func _physics_process(delta: float) -> void:
    if is_on_floor():
        _coyote_timer = COYOTE_TIME_MAX
    else:
        _coyote_timer -= delta
        velocity += get_gravity() * delta
        
    _jump_buffer_timer -= delta
    
    # Check if both timers are valid to execute jump.
    if _jump_buffer_timer > 0.0 and _coyote_timer > 0.0:
        velocity.y = JUMP_VELOCITY
        _jump_buffer_timer = 0.0
        _coyote_timer = 0.0
        
    move_and_slide()
