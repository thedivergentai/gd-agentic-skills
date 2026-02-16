> [!NOTE]
> **Resource Context**: This module provides expert patterns for **Genre: Open World**. Accessed via Godot Master.

# Genre: Open World

Expert blueprint for building massive, seamless open-world games. Focuses on dynamic chunk streaming, floating origin systems to prevent precision errors, and efficient state persistence across unloaded regions.

## Available Scripts

### [world_streamer.gd](../scripts/open_world_world_streamer.gd)
A professional-grade chunk management and streaming engine. Dynamically loads and unloads scene chunks as the player player moves, utilizing background threads to prevent frame stutters during massive asset instantiation.

### [floating_origin_shifter.gd](../scripts/open_world_floating_origin_shifter.gd)
A critical utility for large-scale maps. Detects when the player moves beyond a safety threshold (typically 5,000 units) and physically shifts the entire world back to (0,0,0) to prevent the "jitter" caused by floating-point precision loss at extreme distances.


## NEVER Do

- **NEVER prioritize Map Size over Density** — Huge, empty landscapes are a hallmark of poor design. It is better to have a smaller, hand-crafted, dense world than a vast procedural desert with nothing to do. Focus on "Points of Interest" (POIs) within every 30 seconds of travel.
- **NEVER save the entire world state** — Attempting to save the transform of every tree and rock in a 10km map will lead to massive save files. Use **Delta Persistence**: only record the unique changes made by the player (e.g., a chopped tree, a looted chest).
- **NEVER process Physics/Logic at extreme distances** — Beyond a certain radius, there is no reason for physics bodies or AI to be active. Use **Spatial Partitioning** to disable `_process()` and `_physics_process()` for entities in far-away chunks.
- **NEVER perform Synchronous Chunk Loading** — Loading a 512x512 tilemap or a complex mesh in the same frame as player movement WILL cause a "Loading Hitch." ALWAYS use a background `Thread` or Godot's `ResourceLoader.load_threaded_request()`.
- **NEVER ignore the "Floating Origin" problem** — Once you move past 8,000 to 10,000 units in Godot (or any engine), physics calculations and sub-pixel rendering will start to jitter visibly. You MUST implement a world-shift system.
- **NEVER bake all Collision into one mesh** — Large, monolithic collision meshes are expensive to query. Broke your world into chunks and assign local collision regions to each.

---

## World Streaming Architecture
- **Chunk Size**: Typically **100m to 200m** depending on move speed.
- **Loading Zone**: Use a `render_distance` (e.g., 3x3 or 5x5 chunks around player).
- **Persistence**: When a chunk is unloaded, serialize the state of its interactive entities to a global dictionary before freeing them from memory.

## Solving Floating-Point Precision
When `player.global_position.length() > range_limit`:
1. Calculate `Vector3 offset = -player.global_position`.
2. Apply `offset` to every node in the "World" group.
3. Effectively "Teleport" the entire world so the player is back at (0,0,0) without them noticing.

## HLOD (Hierarchical Level of Detail)
- **Extreme Distance**: A single Billboard or a low-resolution texture of the town.
- **Mid Distance**: A single mesh representing the whole building (no interiors).
- **Near Distance**: High-quality meshes and interactive props.

## POI & Discovery Systems
- **Marker Database**: Store the coordinates of known cities/camps.
- **Compass Logic**: Calculate the angle between `player.forward` and `poi.direction` to display markers on the HUD.

## Performance: Threaded Instantiation
When loading a new chunk:
- Use `instantiate()` in a background thread.
- Use `call_deferred("add_child")` to safely merge the new chunk into the main scene tree without blocking the main rendering thread.

## Reference
- [Godot Docs: Background Loading](https://docs.godotengine.org/en/stable/tutorials/io/background_loading.html)
- [GDC: Open World Streaming in Godot (YouTube)](https://www.youtube.com/watch?v=FjIaoW7tPec)
