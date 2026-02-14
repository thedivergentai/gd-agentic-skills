> [!NOTE]
> **Resource Context**: This module provides expert patterns for **TileMap Mastery**. Accessed via Godot Master.

# TileMap Mastery

TileMapLayer grids, TileSet atlases, terrain autotiling, and custom data define efficient 2D level systems.

## Available Scripts

### [tilemap_data_manager.gd](../scripts/godot-tilemap-mastery_tilemap_data_manager.gd)
Expert TileMap serialization and chunking manager for large worlds.

### [terrain_autotile.gd](../scripts/godot-tilemap-mastery_terrain_autotile.gd)
Runtime terrain autotiling with `set_cells_terrain_connect` batching and validation.

### [tilemap_chunking.gd](../scripts/godot-tilemap-mastery_tilemap_chunking.gd)
Chunk-based TileMap management with batched updates - essential for large procedural worlds.


## NEVER Do

- **NEVER use set_cell() in loops without batching** — Use `set_cells_terrain_connect()` for bulk changes.
- **NEVER forget source_id parameter** — Use the correct overload: `set_cell(pos, source_id, atlas_coords)`.
- **NEVER mix tile coordinates with world coordinates** — ALWAYS convert global positions with `local_to_map(global_pos)`.
- **NEVER query get_cell_tile_data() in _physics_process** — Cache tile data in a dictionary if you need frequent lookups.
- **NEVER use TileMap for dynamic entities** — Reserve TileMap for static/destructible geometry. Use Node2D/CharacterBody2D for interactable objects.

---

## Grid System Basics
```gdscript
# Placement
set_cell(Vector2i(0, 0), 0, Vector2i(0, 0))  # source_id, atlas_coords

# Coordinate Conversion
var mouse_pos := get_global_mouse_position()
var tile_pos := local_to_map(mouse_pos)
```

## Terrain Auto-Tiling
Use Terrain Sets and Terrains to define organic connection rules in the TileSet editor, then paint them in code:
```gdscript
set_cells_terrain_connect([pos], terrain_set_id, terrain_id, false)
```

## Custom Tile Data
Access per-tile properties (like damage value, friction, or destructibility) that you've defined in the TileSet Custom Data Layers:
```gdscript
var tile_data := get_cell_tile_data(tile_pos)
if tile_data:
    var damage := tile_data.get_custom_data("damage_per_second")
```

## Reference
- [Godot Docs: TileMaps](https://docs.godotengine.org/en/stable/tutorials/2d/using_tilemaps.html)
- [Godot Docs: TileSets](https://docs.godotengine.org/en/stable/tutorials/2d/using_tilesets.html)
