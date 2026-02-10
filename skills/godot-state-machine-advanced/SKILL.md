---
name: godot-state-machine-advanced
description: "Expert blueprint for hierarchical finite state machines (HSM) and pushdown automata for complex AI/character behaviors. Covers state stacks, sub-states, transition validation, and state context passing. Use when basic FSMs are insufficient OR implementing layered AI. Keywords state machine, HSM, hierarchical, pushdown automata, state stack, FSM, AI behavior."
---

# Advanced State Machines

Hierarchical states, state stacks, and context passing define complex behavior management.

## Available Scripts

### [hsm_logic_state.gd](scripts/hsm_logic_state.gd)
Expert HSM base class with state stack management and validation.

### [pushdown_automaton.gd](scripts/pushdown_automaton.gd)
Stack-based state machine for interrupt-resume behavior (pause menus, cutscenes).

> **MANDATORY**: Read hsm_logic_state.gd before implementing hierarchical AI behaviors.


## NEVER Do in Advanced State Machines

- **NEVER forget to call exit() before enter()** — Transition without exit? Previous state cleanup skipped = resource leaks (timers, tweens). ALWAYS exit → enter.
- **NEVER use push_state() without pop_state()** — Pushed 100 interrupt states? Stack overflow + memory leak. EVERY push needs matching pop.
- **NEVER modify state during transition** — `transition_to()` called inside `exit()`? Re-entrant transition = undefined behavior. Flag transitions, execute after current completes.
- **NEVER skip state validation** — `transition_to("AttackState")` but state doesn't exist? Silent failure OR crash. Validate state exists before transition.
- **NEVER forget to process child states** — Hierarchical state with sub-states? Parent `update()` must call `current_child_state.update()` for delegation.
- **NEVER use string state names in code** — `transition_to("Idel")` typo = silent failure. Use constants OR enums: `transition_to(States.IDLE)`.

---

```gdscript
# hierarchical_state.gd
class_name HierarchicalState
extends Node

signal transitioned(from_state: String, to_state: String)

var current_state: Node
var state_stack: Array[Node] = []

func  _ready() -> void:
    for child in get_children():
        child.state_machine = self
    
    if get_child_count() > 0:
        current_state = get_child(0)
        current_state.enter()

func transition_to(state_name: String) -> void:
    if not has_node(state_name):
        return
    
    var new_state := get_node(state_name)
    
    if current_state:
        current_state.exit()
    
    transitioned.emit(current_state.name if current_state else "", state_name)
    current_state = new_state
    current_state.enter()

func push_state(state_name: String) -> void:
    if current_state:
        state_stack.append(current_state)
        current_state.exit()
    
    transition_to(state_name)

func pop_state() -> void:
    if state_stack.is_empty():
        return
    
    var previous_state := state_stack.pop_back()
    transition_to(previous_state.name)
```

## State Base Class

```gdscript
# state.gd
class_name State
extends Node

var state_machine: HierarchicalState

func enter() -> void:
    pass

func exit() -> void:
    pass

func update(delta: float) -> void:
    pass

func physics_update(delta: float) -> void:
    pass

func handle_input(event: InputEvent) -> void:
    pass
```

## Best Practices

1. **Separation** - One state per file
2. **Signals** - Communicate state changes
3. **Stack** - Use push/pop for interruptions

## Reference
- Related: `godot-characterbody-2d`, `godot-animation-player`


### Related
- Master Skill: [godot-master](../godot-master/SKILL.md)
