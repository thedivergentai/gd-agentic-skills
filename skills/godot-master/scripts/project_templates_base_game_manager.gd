# skills/project-templates/code/base_game_manager.gd
extends Node

## Project Templates Expert Pattern
## Implements the 'Template Method' pattern for core game loops.

signal state_changed(old_state: String, new_state: String)

var _current_state: String = "INIT"

func _ready() -> void:
    # 1. Abstract Initialization Loop
    # Expert logic: Define the skeleton of the algorithm, 
    # letting subclasses override specific steps.
    _bootstrap_systems()
    _enter_initial_state()

# --- Template Methods (To be overridden) ---

func _bootstrap_systems() -> void:
    # Logic for dependency injection, singleton checks, etc.
    pass

func _enter_initial_state() -> void:
    change_state("MAIN_MENU")

# --- Core Logic ---

func change_state(new_state: String) -> void:
    if _current_state == new_state: return
    
    var old_state = _current_state
    _current_state = new_state
    
    # 2. Lifecycle Hooks
    # Professional pattern: Separate 'Internal Logic' from 'Extensible Hooks'.
    _on_state_exit(old_state)
    _on_state_enter(new_state)
    
    state_changed.emit(old_state, new_state)

func _on_state_exit(_state: String) -> void: pass
func _on_state_enter(_state: String) -> void: pass

## EXPERT NOTE:
## Use 'Modular Initialization': Don't put everything in one script. 
## Create separate 'System' nodes (e.g. SaveSystem, AudioSystem) and 
## have the BaseGameManager coordinate their 'start()' and 'stop()' 
## sequences to ensure correct boot order.
## NEVER hardcode scene transitions; use a centralized 'SceneLoader' 
## singleton called via the 'BaseGameManager' state hooks.
## For 'project-templates', pre-configure a 'test/' directory with 
## a simple GUT test that verifies the 'change_state' logic works 
## before any new logic is added.
