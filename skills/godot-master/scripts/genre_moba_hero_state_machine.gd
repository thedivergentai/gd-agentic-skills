# hero_state_machine.gd
extends Node
class_name HeroStateMachine

# State Machine Pattern Matching with StringNames
# Optimized state switching for deterministic logic in competitive MOBA heroes.

@export var current_state: StringName = &"idle"

func _physics_process(_delta: float) -> void:
    # Fast pointer comparisons using StringNames.
    match current_state:
        &"idle", &"moving":
            _handle_locomotion()
        &"stunned":
            _handle_stun_lock()
        &"casting":
            _handle_ability_channeling()
        _:
            push_error("Hero transitioned to invalid state: ", current_state)

func _handle_locomotion() -> void: pass
func _handle_stun_lock() -> void: pass
func _handle_ability_channeling() -> void: pass
