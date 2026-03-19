# item_state_duplicator.gd
extends Node

# Deep Duplication of Inventory Items (State Management)
# Ensures identical items (like two handguns) can track ammo/durability independently
# by breaking the shared resource link.
func add_unique_item(base_item_resource: Resource) -> Resource:
    # duplicate(true) performs a deep copy of sub-resources.
    # In Godot 4, this ensures unique magazines/attachments for each instance.
    var unique_item := base_item_resource.duplicate(true)
    return unique_item
