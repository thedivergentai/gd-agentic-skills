> [!NOTE]
> **Resource Context**: This module provides expert patterns for **Genre: Survival**. Accessed via Godot Master.

# Genre: Survival

Expert blueprint for building survival games. Focuses on resource management, crafting systems, persistent inventories, and the delicate balance of physiological "Needs" (Hunger, Thirst, Fatigue).

## Available Scripts

### [inventory_slot_resource.gd](../scripts/godot-genre-survival_inventory_slot_resource.gd)
A robust data model for inventory slots. Uses Godot's `Resource` system for easy serialization, enabling seamless save/load functionality for player inventories, storage chests, and dropped loot.


## NEVER Do

- **NEVER use infinite "Needs" decay** — Do not just subtract a constant value from hunger. Decay should scale with activity: **Sprinting** should drain hunger 3x faster than **Standing Idle**. If the player is **Sleeping**, drain should be minimal (0.5x).
- **NEVER use Instant Death for starvation** — Snapping to 0% health the moment hunger hits zero feels "cheap." Instead, trigger a gradual health drain (e.g., -2 HP/sec) and provide a persistent visual/audio warning (camera shake, stomach growls).
- **NEVER allow infinite stacking without weight** — If a player can carry 9,999 stone blocks in one slot, base building becomes trivial. Use **Stack Limits** (e.g., 64 items per slot) or a **Weight Capacity** system to force resource management decisions.
- **NEVER make gathering tedious without progression** — Taking 100 hits to chop a tree is only acceptable at level 1. You MUST implement **Tiered Tool Scaling**: Stone Axe = 1 wood per hit, Steel Axe = 5 wood per hit, Auto-Saw = constant wood generation.
- **NEVER force player to "Guess" crafting recipes** — Trial-and-error crafting is a design relic. Use a **Discovery System**: once a player holds the necessary ingredients, reveal the recipe in their crafting UI for future use.
- **NEVER spawn threats at the Respawn Point** — Spawning into a pack of wolves right after dying is a "rage-quit" moment. Enforce a **Safe Zone radius** around beds or spawn points where enemies are prohibited from spawning.

---

## The Needs System (Physiology)
Implement a central `NeedsManager` checking every frame:
```gdscript
var hunger: float = 100.0
var decay_rate: float = 0.05 # Per second

func _process(delta: float):
    # Adjust decay based on velocity/state
    var active_decay = decay_rate * (1.0 + (player_velocity / max_speed) * 2.0)
    hunger -= active_decay * delta
```

## Inventory and Crafting
- **Data Structure**: Use an `Array[InventorySlot]` where each slot is a custom `Resource`.
- **Crafting**: A function that iterates through the `Inventory`, checks if enough `ItemData` exists for a `Recipe` resource, removes the cost, and adds the `Result` item.

## Resource Gathering (Harvesting)
- Use `Interactable` components on World Objects (Trees, Rocks).
- When hit/used, they emit a `dropped_resource` signal.
- **Juice**: Add a slight "Scale Shake" effect to the object when hit to make the activity feel physical.

## Procedural Spawning
- Use `FastNoiseLite` to generate "Resource Clusters" (e.g., forests or mineral veins) rather than spawning resources randomly. This creates natural-feeling "Biomes" the player must travel between.

## PERSISTENCE (Save/Load)
The survival genre relies on long-term progression.
- Store `Inventory` and `WorldState` (e.g., constructed buildings) in a `JSON` file or a `.tres` resource.
- **Tip**: Serializing `ItemData` resources is as simple as saving their `id` string and their current `amount`.

## Reference
- [Godot Docs: FastNoiseLite for Terrain](https://docs.godotengine.org/en/stable/classes/class_fastnoiselite.html)
- [GDC: The Simulation of Survival](https://www.youtube.com/watch?v=kYv9lS9eU0U)
