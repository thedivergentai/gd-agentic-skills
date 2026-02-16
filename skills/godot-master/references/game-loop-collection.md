# Game Loop: Collections & Scavenger Hunts

> [!NOTE]
> **Resource Context**: This module provides expert patterns for **Collection Loops**. Accessed via Godot Master.

## Architectural Thinking: The "Find-All" Loop

Collection loops are foundational for exploration. A Master implementation distinguishes between **Deterministic Placement** (hand-placed items) and **Procedural Discovery** (spawned within volumes).

### Core Responsibilities
- **Manager**: Single source of truth for "Current / Target" state. Avoids poll-based UI.
- **Spawner**: Decoupled from levels. Can fill `CollisionShape3D` volumes dynamically.

## Expert Code Patterns

### 1. Volume-Aware Procedural Spawner
Master-level spawning detects collision volumes to generate high-density discovery areas without manual effort.

```gdscript
# game_loop_collection_hidden_item_spawner.gd
# Intrinsic Shape Detection
if available_points.is_empty():
    for child in get_children():
        if child is CollisionShape3D:
            _spawn_at(_get_random_point_in_shape(child))
```

### 2. Signal-Based Collection Logic
Items should NOT update UI directly. They emit a signal to the Manager, which manages the tally.

```gdscript
# game_loop_collection_collectible_item.gd
func _on_body_entered(body):
    item_collected.emit(id)
    # Juice: Play sound/VFX BEFORE queue_free
    _play_juice()
    queue_free()
```

## Master Decision Matrix: Spawning Strategy

| Strategy | Best For | Implementation |
| :--- | :--- | :--- |
| **Marker3D** | High-value, unique items | Exact `global_position`. |
| **BoxShape3D** | Large areas / Clutter | `randf_range` on size. |
| **SphereShape3D** | Clusters / Organic spread | `random_on_unit_sphere`. |

## Veteran-Only Gotchas (Never List)

- **NEVER use `get_tree().get_nodes_in_group` every frame**: Caching collectors is fine, but scanning the tree constantly is slow.
- **NEVER hardcode spawn positions in code**: Always use `Marker3D` or `CollisionShape3D` nodes in the scene so designers can adjust layout without touching code.
- **Avoid "God Objects"**: The `CollectionManager` shouldn't handle input, UI, AND audio. Let it emit signals and let other systems react.
- **Juice**: Always spawn particles or play a sound *before* the item disappears. Immediate `queue_free()` feels dry.

## Registry

- **Expert Component**: [collection_manager.gd](../scripts/game_loop_collection_collection_manager.gd)
- **Expert Component**: [collectible_item.gd](../scripts/game_loop_collection_collectible_item.gd)
- **Expert Component**: [hidden_item_spawner.gd](../scripts/game_loop_collection_hidden_item_spawner.gd)
