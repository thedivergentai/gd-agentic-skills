# rts_group_commander.gd
extends Node
class_name RTSGroupCommander

# Decoupled Group Broadcasting for Mass Commands
# Instantly alerts all units in a control group without hardcoded array iteration.

func order_move_group(group_id: StringName, target_pos: Vector3) -> void:
    # Pattern: Use call_group_flags with DEFERRED and UNIQUE for safety and efficiency.
    var flags := SceneTree.GROUP_CALL_DEFERRED | SceneTree.GROUP_CALL_UNIQUE
    
    get_tree().call_group_flags(
        flags,
        group_id,      # Target group (e.g., &"group_1")
        &"move_to",    # Target method in unit script
        target_pos     # Arg
    )
