---
name: godot-tilemap-mastery
description: "Expert blueprint for TileMapLayer and TileSet systems for efficient 2D level design. Covers terrain autotiling, physics layers, custom data, navigation integration, and runtime manipulation. Use when building grid-based levels OR implementing destructible tiles. Keywords TileMapLayer, TileSet, terrain, autotiling, atlas, physics layer, custom data."
---

# TileMap Mastery

TileMapLayer grids, TileSet atlases, terrain autotiling, and custom data define efficient 2D level systems.

## Available Scripts

### [tilemap_data_manager.gd](scripts/tilemap_data_manager.gd)
Expert TileMap serialization and chunking manager for large worlds.

## NEVER Do in TileMaps

- **NEVER use set_cell() in loops without batching** — 1000 tiles × `set_cell()` = 1000 individual function calls = slow. Use `set_cells_terrain_connect()` for bulk OR cache changes, apply once.
- **NEVER forget source_id parameter** — `set_cell(pos, atlas_coords)` without source_id? Wrong overload = crash OR silent failure. Use `set_cell(pos, source_id, atlas_coords)`.
- **NEVER mix tile coordinates with world coordinates** — `set_cell(mouse_position)` without `local_to_map()`? Wrong grid position. ALWAYS convert: `local_to_map(global_pos)`.
- **NEVER skip terrain set configuration** — Manual tile assignment for organic shapes? 100+ tiles for grass patch. Use `set_cells_terrain_connect()` with terrain sets for autotiling.
- **NEVER use TileMap for dynamic entities** — Enemies/pickups as tiles? No signals, physics, scripts. Use Node2D/CharacterBody2D, reserve TileMap for static/destructible geometry.
- **NEVER query get_cell_tile_data() in _physics_process** — Every frame tile data lookup? Performance tank. Cache tile data in dictionary: `tile_cache[pos] = get_cell_tile_data(pos)`.

---

### Step 1: Create TileSet Resource

1. Create a `TileMapLayer` node
2. In Inspector: **TileSet → New TileSet**
3. Click TileSet to open bottom TileSet editor

### Step 2: Add Tile Atlas

1. In TileSet editor: **+ → Atlas**
2. Select your tile sheet texture
3. Configure grid size (e.g., 16x16 pixels per tile)

### Step 3: Add Physics, Collision, Navigation

```gdscript
# Each tile can have:
# - Physics Layer: CollisionShape2D for each tile
# - Terrain: Auto-tiling rules
# - Custom Data: Arbitrary properties
```

**Add collision to tiles:**
1. Select tile in TileSet editor
2. Switch to "Physics" tab
3. Draw collision polygon

## Using TileMapLayer

### Basic Tilemap Setup

```gdscript
extends TileMapLayer

func _ready() -> void:
    # Set tile at grid coordinates (x, y)
    set_cell(Vector2i(0, 0), 0, Vector2i(0, 0))  # source_id, atlas_coords
    
    # Get tile at coordinates
    var atlas_coords := get_cell_atlas_coords(Vector2i(0, 0))
    
    # Clear tile
    erase_cell(Vector2i(0, 0))
```

### Runtime Tile Placement

```gdscript
extends TileMapLayer

func _input(event: InputEvent) -> void:
    if event is InputEventMouseButton and event.pressed:
        var global_pos := get_global_mouse_position()
        var tile_pos := local_to_map(global_pos)
        
        # Place grass tile (assuming source_id=0, atlas=(0,0))
        set_cell(tile_pos, 0, Vector2i(0, 0))
```

### Flood Fill Pattern

```gdscript
func flood_fill(start_pos: Vector2i, tile_source: int, atlas_coords: Vector2i) -> void:
    var cells_to_fill: Array[Vector2i] = [start_pos]
    var original_tile := get_cell_atlas_coords(start_pos)
    
    while cells_to_fill.size() > 0:
        var current := cells_to_fill.pop_back()
        
        if get_cell_atlas_coords(current) != original_tile:
            continue
        
        set_cell(current, tile_source, atlas_coords)
        
        # Add neighbors
        for dir in [Vector2i.UP, Vector2i.DOWN, Vector2i.LEFT, Vector2i.RIGHT]:
            cells_to_fill.append(current + dir)
```

## Terrain Auto-Tiling

### Setup Terrain Set

1. In TileSet editor: **Terrains** tab
2. Add Terrain Set (e.g., "Ground")
3. Add Terrain (e.g., "Grass", "Dirt")
4. Assign tiles to terrain by painting them

### Use Terrain in Code

```gdscript
extends TileMapLayer

func paint_terrain(start: Vector2i, end: Vector2i, terrain_set: int, terrain: int) -> void:
    for x in range(start.x, end.x + 1):
        for y in range(start.y, end.y + 1):
            set_cells_terrain_connect(
                [Vector2i(x, y)],
                terrain_set,
                terrain,
                false  # ignore_empty_terrains
            )
```

## Multiple Layers Pattern

```gdscript
# Scene structure:
# Node2D (Level)
#   ├─ TileMapLayer (Ground)
#   ├─ TileMapLayer (Decoration)
#   └─ TileMapLayer (Collision)

# Each layer can have different:
# - Rendering order (z_index)
# - Collision layers/masks
# - Modulation (color tint)
```

## Physics Integration

### Enable Physics Layer

1. TileSet editor → **Physics Layers**
2. Add physics layer
3. Assign collision shapes to tiles

**Check collision from code:**
```gdscript
func _physics_process(delta: float) -> void:
    # TileMapLayer acts as StaticBody2D
    # CharacterBody2D.move_and_slide() automatically detects tilemap collision
    pass
```

### One-Way Collision Tiles

```gdscript
# In TileSet physics layer settings:
# - Enable "One Way Collision"
# - Set "One Way Collision Margin"

# Character can jump through from below
```

## Custom Tile Data

### Define Custom Data Layer

1. TileSet editor → **Custom Data Layers**
2. Add property (e.g., "damage_per_second: int")
3. Set value for specific tiles

### Read Custom Data

```gdscript
func get_tile_damage(tile_pos: Vector2i) -> int:
    var tile_data := get_cell_tile_data(tile_pos)
    if tile_data:
        return tile_data.get_custom_data("damage_per_second")
    return 0
```

## Performance Optimization

### Use TileMapLayer Groups

```gdscript
# Static geometry: Single large TileMapLayer
# Dynamic tiles: Separate layer for runtime changes
```

### Chunking for Large Worlds

```gdscript
# Split world into multiple TileMapLayer nodes
# Load/unload chunks based on player position

const CHUNK_SIZE := 32

func load_chunk(chunk_coords: Vector2i) -> void:
    var chunk_name := "Chunk_%d_%d" % [chunk_coords.x, chunk_coords.y]
    var chunk := TileMapLayer.new()
    chunk.name = chunk_name
    chunk.tile_set = base_tileset
    add_child(chunk)
    # Load tiles for this chunk...
```

## Navigation Integration

### Setup Navigation Layer

1. TileSet editor → **Navigation Layers**
2. Add navigation layer
3. Paint navigation polygons on tiles

**Use with NavigationAgent2D:**
```gdscript
# Navigation automatically created from TileMap
# NavigationAgent2D.get_next_path_position() works immediately
```

## Best Practices

### 1. Organize TileSet by Purpose

```
TileSet Layers:
- Ground (terrain=grass, dirt, stone)
- Walls (collision + rendering)
- Decoration (no collision, overlay)
```

## Available Scripts

> **MANDATORY**: Read before implementing terrain systems or runtime placement.

### [terrain_autotile.gd](scripts/terrain_autotile.gd)
Runtime terrain autotiling with `set_cells_terrain_connect` batching and validation.

### [tilemap_chunking.gd](scripts/tilemap_chunking.gd)
Chunk-based TileMap management with batched updates - essential for large procedural worlds.

### 2. Use Terrain for Organic Shapes

```gdscript
# ✅ Good - smooth terrain transitions
set_cells_terrain_connect(tile_positions, 0, 0)

# ❌ Bad - manual tile assignment for organic shapes
for pos in positions:
    set_cell(pos, 0, Vector2i(0, 0))
```

### 3. Layer Z-Index Management

```gdscript
# Background layers
$Background.z_index = -10

# Ground layer
$Ground.z_index = 0

# Foreground decoration
$Foreground.z_index = 10
```

## Common Patterns

### Destructible Tiles

```gdscript
func destroy_tile(world_pos: Vector2) -> void:
    var tile_pos := local_to_map(world_pos)
    var tile_data := get_cell_tile_data(tile_pos)
    
    if tile_data and tile_data.get_custom_data("destructible"):
        erase_cell(tile_pos)
        # Spawn particle effect, drop items, etc.
```

### Tile Highlighting

```gdscript
@onready var highlight_layer: TileMapLayer = $HighlightLayer

func highlight_tile(tile_pos: Vector2i) -> void:
    highlight_layer.clear()
    highlight_layer.set_cell(tile_pos, 0, Vector2i(0, 0))
```

## Reference
- [Godot Docs: TileMaps](https://docs.godotengine.org/en/stable/tutorials/2d/using_tilemaps.html)
- [Godot Docs: TileSets](https://docs.godotengine.org/en/stable/tutorials/2d/using_tilesets.html)


### Related
- Master Skill: [godot-master](../godot-master/SKILL.md)
