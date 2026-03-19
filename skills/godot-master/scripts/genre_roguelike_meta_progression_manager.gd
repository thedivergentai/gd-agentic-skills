# skills/genre-roguelike/scripts/meta_progression_manager.gd
extends Node

## Meta Progression Manager (Expert Pattern)
## Handles persistent data across runs, including currency, unlocks, and stats.
## Uses secure saving/loading to prevent casual tampering.

class_name MetaProgressionManager

signal currency_changed(new_amount: int)
signal upgrade_purchased(upgrade_id: String, new_level: int)

const SAVE_PATH = "user://meta_progression.save"
const SECRET_KEY = "CHANGE_ME_IN_PROD" # Use a proper key management strategy

# Data Structure
var save_data: Dictionary = {
    "currency": 0,
    "total_runs": 0,
    "unlocked_items": [],
    "upgrades": {} # upgrade_id: level
}

func _ready() -> void:
    load_progress()

func add_currency(amount: int) -> void:
    save_data["currency"] += amount
    currency_changed.emit(save_data["currency"])
    save_progress()

func purchase_upgrade(upgrade_id: String, cost: int) -> bool:
    if save_data["currency"] >= cost:
        save_data["currency"] -= cost
        if not save_data["upgrades"].has(upgrade_id):
            save_data["upgrades"][upgrade_id] = 0
        save_data["upgrades"][upgrade_id] += 1
        
        currency_changed.emit(save_data["currency"])
        upgrade_purchased.emit(upgrade_id, save_data["upgrades"][upgrade_id])
        save_progress()
        return true
    return false

func get_upgrade_level(upgrade_id: String) -> int:
    return save_data["upgrades"].get(upgrade_id, 0)

func save_progress() -> void:
    var file = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
    if file:
        var json_str = JSON.stringify(save_data)
        # Simple obfuscation (XOR or base64) to deter casual edits
        # For real security, use FileAccess.open_encrypted_with_pass
        var encrypted = Marshalls.utf8_to_base64(json_str) 
        file.store_string(encrypted)
        file.close()

func load_progress() -> void:
    if not FileAccess.file_exists(SAVE_PATH):
        return

    var file = FileAccess.open(SAVE_PATH, FileAccess.READ)
    if file:
        var encrypted = file.get_as_text()
        var json_str = Marshalls.base64_to_utf8(encrypted)
        var json = JSON.new()
        var parse_result = json.parse(json_str)
        if parse_result == OK:
            save_data = json.data
        else:
            printerr("Save file corrupted!")
        file.close()

## EXPERT USAGE:
## Autoload this script. Call add_currency() at end of run. 
## Check get_upgrade_level() during gameplay to apply buffs.
