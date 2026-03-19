# animation_condition_sync.gd
extends Node
class_name AnimationConditionSync

# AnimationTree Advance Condition Sync
# Synchronizes internal logic state with AnimationTree parameters safely.

@export var anim_tree: AnimationTree

func update_parameters(moving: bool, attacking: bool) -> void:
    if not anim_tree: return
    
    # Pattern: AnimationTree Advance Conditions are Booleans.
    # NEVER use negation (!) in the editor expression; pass explicit bools.
    anim_tree.set("parameters/conditions/is_moving", moving)
    anim_tree.set("parameters/conditions/is_attacking", attacking)
    
    # Important: Ensure the conditions in the state machine match exactly.
