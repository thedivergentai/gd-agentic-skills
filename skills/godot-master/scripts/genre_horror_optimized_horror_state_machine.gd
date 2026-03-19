# optimized_horror_state_machine.gd
extends Node

# Advanced State Machine Pattern Matching (Monster AI)
# Uses Godot 4's high-speed Enum/StringName matching for monster behavior.
var _active_state: StringName = &"patrol"

func _physics_process(_delta: float) -> void:
    match _active_state:
        # StringNames are pointer-compared, far faster than standard string hashing.
        &"patrol":
            _handle_patrol()
        &"chase":
            _handle_chase()
        &"search":
            _handle_search()
        _:
            # Fallback for undefined states.
            pass

func _handle_patrol() -> void: pass
func _handle_chase() -> void: pass
func _handle_search() -> void: pass
