> [!NOTE]
> **Resource Context**: This module provides expert patterns for **Genre: Roguelike**. Accessed via Godot Master.

# Genre: Roguelike

Expert blueprint for Roguelikes and Roguelites. Focuses on the core loop of procedural generation (BSP/Walker), run state isolation, seeded RNG, and permanent meta-progression systems.

## Available Scripts

### [meta_progression_manager.gd](../scripts/godot-genre-roguelike_meta_progression_manager.gd)
A foundational script for Roguelites. Manages the persistent state that survives between player deaths, including currency unlocks, skill tree levels, and global character modifiers. Handles secure data saving to `user://`.


## NEVER Do

- **NEVER make runs dependent on pure RNG** — A good roguelike should allow player skill to overcome bad luck. Provide mechanics like **Rerolls**, **Item Shops**, or **Pity Timers** to ensure every run is potentially winnable.
- **NEVER use unseeded RNG for world generation** — If you don't use a seed (e.g., `RandomNumberGenerator.new().seed = X`), you can never replicate a specific run for bug testing or player-sharing. Always initialize your generator with a predictable seed.
- **NEVER allow "Save Scumming" in a strict roguelike** — Players will try to force-quit to avoid death. Save the run state only at transition points (e.g., between floors) and consider deleting the "Mid-Run" save file immediately upon loading it.
- **NEVER make Meta-Progression upgrades over-powered** — If a +100% Damage upgrade can be bought, the game stops being about skill and becomes a "grind to win" experience. Keep permanent upgrades subtle and focused on utility or horizontal progression.
- **NEVER allow Run State to leak into Meta State** — Ensure that temporary items and buffs acquired during a run are completely purged from memory when the run ends. Use separate Singleton AutoLoads for `RunManager` and `MetaManager`.
- **NEVER forget to handle Navigation re-baking** — If your level is procedurally generated at runtime, the `NavigationServer` or `NavigationRegion2D` must be re-baked AFTER the tiles are placed, or enemies will be unable to pathfind.

---

## Run State vs. Meta State
- **Run State**: Resets on death. Includes Health, XP, Inventory, and current Floor.
- **Meta State**: Persistent across all runs. Includes Total Gold, Unlocked Classes, and Skill Tree progress.

## Procedural Dungeon Generation
Common algorithms for Roguelikes:
- **Drunkard's Walk (Walker)**: Good for organic, cave-like layouts.
- **Binary Space Partitioning (BSP)**: Ideal for rectangular, connected room-and-hallway dungeons.
- **Wave Function Collapse (WFC)**: For highly detailed, rule-based tile environments.

## The Seeded RNG Pattern
```gdscript
var rng = RandomNumberGenerator.new()
rng.seed = hash("MyShareableRunSeed")
# Every call to rng.randi() will now be identical across all machines
```

## Meta-Progression (Upgrades)
Store your upgrades in a `Dictionary` or custom `Resource` saved to `user://`.
- `unlocked_features: Array[String]`
- `stat_bonuses: Dictionary` (e.g., {"extra_health": 2})

## Replayability Through Content
Procedural generation only shuffles your assets. Replayability comes from:
- **Synergy Systems**: Items that become stronger when combined (e.g., "Fire Damage" + "Exploding Projectiles").
- **Director AI**: Balancing the difficulty based on the player's performance during the current run.

## Reference
- [Godot Docs: Random Number Generation](https://docs.godotengine.org/en/stable/tutorials/math/random_number_generation.html)
- [Roguelike Celebration (YouTube)](https://www.youtube.com/@RoguelikeCelebration)
