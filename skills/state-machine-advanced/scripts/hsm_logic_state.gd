# skills/state-machine-advanced/code/hsm_logic_state.gd
extends Node

## State Machine Expert Pattern
## Implements Hierarchical Logic (HSM) and Pushdown Automata.

class State:
    var parent_state: State = null
    var name: String = ""
    
    func enter(_msg: Dictionary = {}) -> void: pass
    func exit() -> void: pass
    func update(_delta: float) -> void: pass
    func handle_input(_event: InputEvent) -> void: pass

# 1. Pushdown Automaton (State Stack)
# Professional pattern: Allow temporary overrides (Stun, Menu) with fallback.
var _state_stack: Array[State] = []
var current_state: State:
    get: return _state_stack.back() if not _state_stack.is_empty() else null

func push_state(new_state: State, msg: Dictionary = {}) -> void:
    if current_state:
        current_state.exit()
    _state_stack.append(new_state)
    new_state.enter(msg)

func pop_state() -> void:
    if _state_stack.size() <= 1: return
    current_state.exit()
    _state_stack.pop_back()
    current_state.enter()

# 2. Hierarchical Logic (HSM)
# Expert logic: Parent-child relationships for sharing common behavior.
func _process(delta: float) -> void:
    var state = current_state
    while state:
        state.update(delta)
        # 3. Propagate logic up the hierarchy
        # e.g. If 'Jumping' doesn't handle a 'Pause' input, 'InAir' might.
        state = state.parent_state

## EXPERT NOTE:
## For 'Save-Game Compatibility', serialize the '_state_stack' 
## as an array of 'StateName' strings.
## Use 'Signal-Driven Transitions': Instead of polling 'is_on_floor', 
## connect character signals to 'FSM.transition()' calls for 
## event-driven architecture.
## Use 'State Data Payloads': Pass complex dictionaries during 
## 'push_state(new_state, {"knockback": Vector3.UP})' to initialize 
## states without global variables.
## NEVER transition to a state if it is already active; use a 
## 'can_transition_to' check to avoid recursive overflows.
