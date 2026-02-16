# godot-master/scripts/animation_tree_nested_state_machine.gd
extends AnimationTree

## Hierarchical State Machine Expert Pattern
## Technical blueprints for building complex "Sub-Level" states.

func _ready() -> void:
    # 1. Hierarchy Logic
    # MainSM (Root) -> LocomotionSM (Nested) -> [Idle, Walk, Run]
    
    # 2. Triggering a sub-state transition
    _travel_to_locomotion()

func _travel_to_locomotion() -> void:
    var state_machine_accessor = get("parameters/playback")
    if state_machine_accessor:
        state_machine_accessor.travel("Locomotion")

func set_locomotion_speed(speed: float) -> void:
    # 3. Driving parameters deep inside nested blend trees
    # Expert Path Syntax: "<StateName>/<BlendNodeName>/blend_position"
    set("parameters/Locomotion/BlendSpace2D/blend_position", speed)

## EXPERT NOTE:
## Nested state machines prevent "Spider-Web Graph" syndrome. 
## Keep 'Locomotion', 'Combat', and 'Interaction' as separate sub-graphs.
