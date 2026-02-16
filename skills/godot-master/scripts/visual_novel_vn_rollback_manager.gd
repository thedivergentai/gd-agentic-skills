# godot-master/scripts/visual_novel_vn_rollback_manager.gd
extends Node

## VN Rollback Expert Pattern
## Manages state snapshots for multi-level history undo.

@export var max_history: int = 50

# Array of Dictionaries representing state at each dialogue step
var _history: Array[Dictionary] = []

# Current live state
var game_state: Dictionary = {
    "dialogue_id": "start",
    "flags": {},
    "current_bg": "park",
    "character_positions": {}
}

func take_snapshot() -> void:
    # 1. Recursive Deep Copy of State
    var snapshot = game_state.duplicate(true)
    _history.append(snapshot)
    
    if _history.size() > max_history:
        _history.remove_at(0)

func rollback() -> bool:
    # 2. Multi-Level Undo
    if _history.is_empty(): 
        return false
        
    game_state = _history.pop_back()
    _apply_state()
    return true

func _apply_state() -> void:
    # Logic to restore the world based on game_state
    # E.g. Update UI, hide/show characters, change background
    print("Rollback to: ", game_state.dialogue_id)

func set_flag(flag: String, value: Variant) -> void:
    # 3. Predictable State Mutation
    # Always take a snapshot BEFORE changing global flags.
    take_snapshot()
    game_state.flags[flag] = value

## EXPERT NOTE:
## Use the 'Command Pattern' for non-trivial state changes (like inventory). 
## For 'genre-visual-novel', implement 'Character Sprite Layering' where a 
## single Actor node can have its 'base', 'eyes', 'mouth', and 'clothes' 
## textures swapped independently via game_state variables.
## NEVER hardcode dialogue; use a JSON parser to map game_state.dialogue_id 
## to specific lines in a localization-ready data file.
