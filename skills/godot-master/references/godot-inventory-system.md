> [!NOTE]
> **Resource Context**: This module provides expert patterns for **Inventory Systems**. Accessed via Godot Master.

# Inventory System

Expert blueprint for inventory management, including slot-based containers, stacking logic, grid-based "Tetris" inventories, and equipment systems.

## Available Scripts

### [grid_inventory_logic.gd](../scripts/godot-inventory-system_grid_inventory_logic.gd)
Expert logic for traditional grid-based inventories. Handles item rotation, rectangular fit checks, and multi-slot occupation.

### [inventory_grid.gd](../scripts/godot-inventory-system_inventory_grid.gd)
Controller for grid UI. Integrates with drag-and-drop signals and provides auto-sorting algorithms for space optimization.


## NEVER Do

- **NEVER use Nodes for inventory items** — Creating hundreds of `Node` instances for items will cause massive performance and memory overhead. Extend `Resource` instead.
- **NEVER forget to check `max_stack`** — Always verify if an item can be merged into an existing slot before creating a new one to prevent fragmented inventories.
- **NEVER modify the Inventory model from the UI layer** — UI nodes should only emit signals. Let the `Inventory` resource handle the data change, then have the UI refresh itself in response to a `changed` signal.
- **NEVER use `float` for item quantities** — Floating point errors lead to items vanishing or duplicating. Use `int` for counts and only use `float` for weight or volume limits.
- **NEVER emit `inventory_changed` inside a loop** — When adding 50 items, emit the signal ONE TIME after the loop finishes to avoid 50 redundant UI redraws.

---

## Core Architecture: Resource-Based Items
Define an `Item` resource base. Use sub-classes or exported properties to define behavior (e.g., `Weapon`, `Consumable`, `QuestItem`).

## Stacking Logic Flow
1. **Match**: Find slots containing the same `Item` ID.
2. **Space**: Check if `current_amount < max_stack`.
3. **Fill**: Add as much as possible to the existing slot.
4. **Overflow**: If items are left over, find the next empty slot.

## Grid Inventory (Tetris Style)
Items occupy a `Rect2i` within a larger grid.
- **Fit Check**: Ensure the proposed bounding box is within grid bounds AND does not overlap existing occupied cells.
- **Rotation**: Swap width and height of the item's occupation rect before checking fit.

## Equipment Pattern
Use a dedicated `Equipment` resource with specific slots (Head, Chest, MainHand). 
- **Equipping**: Removes item from inventory and places it in the equipment slot; returns the previously equipped item to the player's inventory.
- **Stat Calculation**: Sum up modifiers from all equipped items whenever the equipment state changes.

## Crafting Integration
Create `Recipe` resources that define an array of `RequiredItem` resources. The `CraftingManager` verifies that the `Inventory` has sufficient counts of all requirements before removing them and adding the `CraftedItem`.

## Reference
- [Godot Docs: Drag and Drop UI](https://docs.godotengine.org/en/stable/tutorials/ui/drag_and_drop.html)
- [Godot Docs: Resource Saving/Loading](https://docs.godotengine.org/en/stable/tutorials/io/saving_games.html#saving-and-loading-resources)
