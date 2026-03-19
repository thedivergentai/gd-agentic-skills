# hierarchical_state_base.gd
extends Node
class_name HierarchicalStateBase

# Hierarchical State Machine Base
# Modular base for complex RPG AI and Player state logic.

@export var initial_state: Node
@onready var current_state: Node = initial_state

func _physics_process(delta: float) -> void:
    # Pattern: Delegate the tick to the active specialized state script.
    if current_state and current_state.has_method(&"physics_tick"):
        current_state.physics_tick(delta)

func transition(target_path: NodePath, params: Dictionary = {}) -> void:
    var next_state = get_node_or_null(target_path)
    if not next_state: return
    
    if current_state.has_method(&"on_exit"):
        current_state.on_exit()
        
    current_state = next_state
    
    if current_state.has_method(&"on_enter"):
        current_state.on_enter(params)
