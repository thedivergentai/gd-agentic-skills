# coyote_timer.gd
extends Node
class_name CoyoteTimer

# Coyote Time Logic
# Tracks the precise time since the player left the floor to grant a brief jump window.

var time_left: float = 0.0
const MAX_COYOTE: float = 0.15

func update_coyote(is_on_floor: bool, delta: float) -> void:
    if is_on_floor:
        time_left = MAX_COYOTE
    else:
        time_left -= delta

func can_jump() -> bool:
    # Pattern: Avoid exact floating point equality (== 0.0).
    return time_left > 0.0
