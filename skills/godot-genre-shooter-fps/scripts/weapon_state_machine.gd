# weapon_state_machine.gd
extends Node
class_name WeaponStateMachine

# StringName-Optimized Weapon State Machine
# High-performance state transitions for fast firing loops.

# Pattern: Use &StringNames for pointer-level hash comparisons.
var current_state: StringName = &"idle"

func _physics_process(delta: float) -> void:
    match current_state:
        &"idle":
            if Input.is_action_pressed(&"fire"):
                transition_to(&"firing")
        &"firing":
            if not Input.is_action_pressed(&"fire"):
                transition_to(&"idle")
        &"reloading":
            pass

func transition_to(new_state: StringName) -> void:
    current_state = new_state
    # Handle entry/exit logic here.
