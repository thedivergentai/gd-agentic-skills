> [!NOTE]
> **Resource Context**: This module provides expert patterns for **Procedural Generation**. Accessed via Godot Master.

# Procedural Generation

Expert blueprint for procedural content generation (PCG) including noise-based terrain, BSP dungeons, and Wave Function Collapse (WFC).

## Available Scripts

### [wfc_level_generator.gd](../scripts/procedural_generation_wfc_level_generator.gd)
Expert implementation of the Wave Function Collapse algorithm. Manages tile adjacency rules, entropy calculations, and propagation to create complex, structurally sound levels from small samples.


## NEVER Do

- **NEVER forget to seed your Random Number Generator** — Initializing `RandomNumberGenerator.new()` without a seed will lead to identical results every run. Always provide a unique seed or hash the system time.
- **NEVER use `randf()` at the start of a scene in multiplayer** — Each client will generate a different result, leading to immediate out-of-sync errors. Always sync the master seed from the server.
- **NEVER skip playability validation** — A procedural dungeon is useless if it has no path from start to end. Always use a pathfinding algorithm (A*) after generation to verify connectivity or regenerate if needed.
- **NEVER sample noise functions every frame** — Calling `get_noise_2d()` inside `_process` for thousands of units will tank performance. Pre-calculate values into a heightmap array or image during initialization.
- **NEVER split BSP rooms without a minimum size check** — Infinite recursions will lead to 1x1 rooms and engine crashes. Always define and enforce a `min_room_size`.
- **NEVER ignore WFC contradictions** — If the WFC solver reaches a state with zero valid tile options, it must be programmed to backtrack or restart entirely rather than crashing.
- **NEVER generate large worlds on the main thread** — Massive PCG operations (e.g., 1000x1000 worlds) cause the UI to freeze. Use `WorkerThreadPool` to generate data in the background.

---

## Noise-Based Terrain (FastNoiseLite)
1. Initialize a `FastNoiseLite` resource.
2. Set `frequency`, `noise_type` (Perlin, Simplex), and `seed`.
3. Sample noise to determine tile types (e.g., `< 0.0` = Water, `0.0 to 0.4` = Plains, `> 0.4` = Mountains).

## BSP Dungeon Pattern (Binary Space Partition)
1. start with a rectangle representing the whole floor.
2. Recursively split the rectangle horizontally or vertically until rooms reach a target size.
3. Place a room within each leaf node of the partition tree.
4. Draw corridors between sibling nodes to ensure all rooms are connected.

## Wave Function Collapse (Constraint Propagation)
WFC treats a level as a grid of "uncollapsed" possibilities.
1. Define adjacency rules (e.g., "Sea" can touch "Beach", but not "Desert").
2. Find the cell with the **lowest entropy** (fewest valid tile options).
3. **Collapse** it to a single tile.
4. **Propagate** the new constraints to neighboring cells.
5. Repeat until all cells are collapsed.

## Seeding for Reproducibility
Store your level seed:
`var current_seed = hash("World42")`
This allows players to share "seeds" and allows developers to recreate specific bugged generations for debugging.

## Reference
- [Godot Docs: Random Number Generation](https://docs.godotengine.org/en/stable/tutorials/math/random_number_generation.html)
- [Godot Docs: FastNoiseLite](https://docs.godotengine.org/en/stable/classes/class_fastnoiselite.html)
