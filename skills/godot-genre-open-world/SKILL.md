---
name: godot-genre-open-world
description: "Expert blueprint for open world games including chunk-based streaming (load/unload regions dynamically), floating origin (prevent precision jitter beyond 5000 units), HLOD (hierarchical LOD for distant meshes), persistent state (track entity changes across unloaded chunks), POI discovery systems (compass, markers), and threaded loading (prevent stutters). Use for RPGs, sandboxes, or exploration games. Trigger keywords: open_world, chunk_streaming, floating_origin, HLOD, persistent_state, POI_discovery, threaded_loading."
---

# Genre: Open World

Expert blueprint for open worlds balancing scale, performance, and player engagement.

## NEVER Do

- **NEVER prioritize size over density** — Huge empty maps are boring. Smaller, denser maps beat vast deserts. Density > Size.
- **NEVER save everything** — 500MB save files destroy performance. Save only *changes* (delta compression). Unmodified objects use defaults.
- **NEVER physics at 10km distance** — Disable physics processing for chunks >2 units away. Use simple simulation (timers) for distant logic.
- **NEVER ignore floating point precision** — At 5000+ units, objects jitter. Implement floating origin: shift world when player exceeds threshold.
- **NEVER synchronous chunk loading** — Loading chunks in _process() causes stutters. Use Thread.new() for background loading.
---

## Available Scripts

> **MANDATORY**: Read the appropriate script before implementing the corresponding pattern.

### [floating_origin_shifter.gd](scripts/floating_origin_shifter.gd)
Shifts world origin when player exceeds threshold distance from (0,0,0). Prevents floating-point precision jitter at large distances.

---

## Core Loop
1.  **Traverse**: Player moves across vast distances (foot, vehicle, mount).
2.  **Discover**: Player finds Points of Interest (POIs) dynamically.
3.  **Quest**: Player accepts tasks that require travel.
4.  **Progress**: World state changes based on player actions.
5.  **Immerse**: Dynamic weather, day/night cycles affect gameplay.

## Skill Chain

| Phase | Skills | Purpose |
|-------|--------|---------|
| 1. Tera | `godot-3d-world-building`, `shaders` | Large scale terrain, tri-planar mapping |
| 2. Opti | `level-of-detail`, `multithreading` | HLOD, background loading, occlusion |
| 3. Data | `godot-save-load-systems` | Saving state of thousands of objects |
| 4. Nav | `godot-navigation-pathfinding` | AI pathfinding on large dynamic maps |
| 5. Core | `floating-origin` | Preventing precision jitter at 10,000+ units |

## Architecture Overview

### 1. The Streamer (Chunk Manager)
Loading and unloading the world around the player.

```gdscript
# world_streamer.gd
extends Node3D

@export var chunk_size: float = 100.0
@export var render_distance: int = 4
var active_chunks: Dictionary = {}

func _process(delta: float) -> void:
    var player_chunk = Vector2i(player.position.x / chunk_size, player.position.z / chunk_size)
    update_chunks(player_chunk)

func update_chunks(center: Vector2i) -> void:
    # 1. Determine needed chunks
    var needed = []
    for x in range(-render_distance, render_distance + 1):
        for y in range(-render_distance, render_distance + 1):
            needed.append(center + Vector2i(x, y))
    
    # 2. Unload old
    for chunk in active_chunks.keys():
        if chunk not in needed:
            unload_chunk(chunk)
    
    # 3. Load new (Threaded)
    for chunk in needed:
        if chunk not in active_chunks:
            load_chunk_async(chunk)
```

### 2. Floating Origin
Solving the floating point precision error (jitter) when far from (0,0,0).

```gdscript
# floating_origin.gd
extends Node

const THRESHOLD: float = 5000.0

func _process(delta: float) -> void:
    if player.global_position.length() > THRESHOLD:
        shift_world(-player.global_position)

func shift_world(offset: Vector3) -> void:
    # Move the entire world opposite to the player's position
    # So the player creates the illusion of moving, but logic stays near 0,0
    for node in get_tree().get_nodes_in_group("world_root"):
        node.global_position += offset
```

### 3. Quest State Database
Tracking "Did I kill the bandits in Chunk 45?" when Chunk 45 is unloaded.

```gdscript
# global_state.gd
var chunk_data: Dictionary = {} # Vector2i -> Dictionary

func set_entity_dead(chunk_id: Vector2i, entity_id: String) -> void:
    if not chunk_data.has(chunk_id):
        chunk_data[chunk_id] = {}
    chunk_data[chunk_id][entity_id] = { "dead": true }
```

## Key Mechanics Implementation

### HLOD (Hierarchical Level of Detail)
Merging 100 houses into 1 simple mesh when viewed from 1km away.
*   **Near**: High Poly House + Props.
*   **Far**: Low Poly Billboard / Imposter mesh.
*   **Very Far**: Part of the Terrain texture.

### Points of Interest (Discovery)
Compass bar logic.

```gdscript
func update_compass() -> void:
    for poi in active_pois:
        var direction = player.global_transform.basis.z
        var to_poi = (poi.global_position - player.global_position).normalized()
        var angle = direction.angle_to(to_poi)
        # Map angle to UI position
```

## Godot-Specific Tips

*   **VisibilityRange**: Use specific `visibility_range_begin` and `end` on MeshInstance3D to handle LODs without a dedicated LOD node.
*   **Thread**: Use `Thread.new()` for loading chunks to prevent frame stutters.
*   **OcclusionCulling**: Bake occlusion for large cities. For open fields, simple distance culling is often enough.

## Common Pitfalls

1.  **The "Empty" World**: huge map, nothing to do. **Fix**: Density > Size. Smaller, denser maps are better than vast empty deserts.
2.  **Save File Bloat**: Save file is 500MB. **Fix**: Only save *changes* (Delta compression). If a rock hasn't moved, don't save it.
3.  **Physics at Distance**: Physics break far away. **Fix**: Disable physics processing for chunks > 2 units away. Use simple "simulation" for distant logic.


## Reference
- Master Skill: [godot-master](../godot-master/SKILL.md)
