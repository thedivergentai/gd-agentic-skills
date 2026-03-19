# inventory_data_storage.gd
extends Node

# Strictly Typed Inventory Data Dictionary (RE/Silent Hill Style)
# Decouples inventory logic from the visual UI grid to ensure data integrity.
# Uses StringName (&"name") for optimized pointer-level lookups in the dictionary.
var inventory: Dictionary[StringName, Resource] = {
    &"mansion_key": null,
    &"handgun_ammo": null
}

func has_item(item_id: StringName) -> bool:
    return inventory.has(item_id) and inventory[item_id] != null
