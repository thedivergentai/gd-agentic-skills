# ability_state_machine.gd
extends Node
class_name AbilityStateMachine

# Player Ability State Machine
# Uses Godot 4's high-speed Enum/StringName matching for traversal states.

@export var current_state: StringName = &"idle"

func _physics_process(_delta: float) -> void:
    # Uses advanced pattern matching for fast state evaluation.
    match current_state:
        &"idle", &"running":
            _process_basic_locomotion()
        &"dashing":
            _process_dash_physics()
        &"wall_sliding":
            _process_wall_slide()
        _:
            # Log unknown states instead of failing silently.
            push_warning("Unexpected player state: ", current_state)

func _process_basic_locomotion() -> void: pass
func _process_dash_physics() -> void: pass
func _process_wall_slide() -> void: pass
