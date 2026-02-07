# skills/genre-metroidvania/scripts/progression_gate_manager.gd
extends Node

## Progression Gate Manager
## Tracks persistent world state and ability unlocks using a singleton pattern (AutoLoad).

class_name ProgressionGateManager

signal ability_unlocked(ability_name: String)
signal gate_opened(gate_id: String)

# Persistent Data
var unlocked_abilities: Dictionary = {}
var opened_gates: Dictionary = {}

func _ready() -> void:
    # In a full game, load this from SaveFile
    pass

func grant_ability(ability_name: String) -> void:
    if not has_ability(ability_name):
        unlocked_abilities[ability_name] = true
        ability_unlocked.emit(ability_name)
        print("Ability Unlocked: %s" % ability_name)

func has_ability(ability_name: String) -> bool:
    return unlocked_abilities.get(ability_name, false)

func open_gate(gate_id: String) -> void:
    if not is_gate_open(gate_id):
        opened_gates[gate_id] = true
        gate_opened.emit(gate_id)

func is_gate_open(gate_id: String) -> bool:
    return opened_gates.get(gate_id, false)

func reset_progress() -> void:
    unlocked_abilities.clear()
    opened_gates.clear()

## EXPERT USAGE:
## access via 'ProgressionGateManager' autoload.
## check `if ProgressionGateManager.has_ability("DoubleJump")` in Player.
