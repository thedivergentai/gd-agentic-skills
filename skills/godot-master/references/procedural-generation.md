---
name: godot-procedural-generation
description: "Expert blueprint for procedural content generation (dungeons, terrain, loot, levels) using FastNoiseLite, random walks, BSP trees, Wave Function Collapse, and seeded randomization. Use when creating roguelikes, sandbox games, or dynamic content. Keywords procedural, generation, FastNoiseLite, Perlin noise, BSP, drunkard walk, Wave Function Collapse, seeding."
---

# Procedural Generation

Seeded algorithms, noise functions, and constraint propagation define replayable content generation.

## Available Scripts

### [fast_noise_noise2d_master.gd](../scripts/procedural_generation_fast_noise_noise2d_master.gd)
Advanced usage of `FastNoiseLite` with image-based sampling for maximum performance.

### [cellular_automata_dungeon.gd](../scripts/procedural_generation_cellular_automata_dungeon.gd)
The classic 4-5 rule implementation for organic cave and terrain generation.

### [poisson_disk_sampling_2d.gd](../scripts/procedural_generation_poisson_disk_sampling_2d.gd)
Blue-noise distribution algorithm for non-clumping object and enemy placement.

### [multi_threaded_chunk_gen.gd](../scripts/procedural_generation_multi_threaded_chunk_gen.gd)
Expert pattern for offloading procedural generation to the `WorkerThreadPool`.

### [drunknard_walk_path.gd](../scripts/procedural_generation_drunknard_walk_path.gd)
Lightweight algorithm for generating winding paths, tunnels, and rivers.

### [marching_squares_metaballs.gd](../scripts/procedural_generation_marching_squares_metaballs.gd)
Implementing the Marching Squares algorithm for smooth contouring and influential maps.

### [bsp_tree_rooms.gd](../scripts/procedural_generation_bsp_tree_rooms.gd)
Binary Space Partitioning for generating structured, non-overlapping floor plans.

### [wave_function_collapse_lite.gd](../scripts/procedural_generation_wave_function_collapse_lite.gd)
Foundation for Wave Function Collapse (WFC) using entropy-based adjacency rules.

### [mesh_gen_infinite_terrain.gd](../scripts/procedural_generation_mesh_gen_infinite_terrain.gd)
Runtime 3D terrain generation using `ArrayMesh` and `SurfaceTool` with LOD potential.

### [l_system_tree_gen.gd](../scripts/procedural_generation_l_system_tree_gen.gd)
L-System string grammar for procedural plant and tree growth in 3D.

### [wfc_level_generator.gd](../scripts/procedural_generation_wfc_level_generator.gd)
Expert Wave Function Collapse implementation with tile adjacency rules.

## NEVER Do in Procedural Generation

- **NEVER generate chunks on the Main Thread** — Proc-gen is CPU intensive and causes frame-rate spikes. Use `WorkerThreadPool` or a background `Thread` to keep the UI responsive.
- **NEVER query `FastNoiseLite` every frame** — Sampling noise per frame (especially in `_process`) is a massive waste. Generate your map into an `Image` or `Array` once and sample from memory [NoiseSampling].
- **NEVER use `randi()` for reproducible seeds** — Always store and reuse a specific `seed` within your random number generator (`RandomNumberGenerator.new()`) to ensure consistent world generation.
- **NEVER use pure randomness for object placement** — Pure random (white noise) causes clumping and overlapping. Use **Poisson Disk Sampling** or **Jittered Grids** for natural-looking distributions.
- **NEVER forget to bound your loops** — Procedural loops (like WFC or Cellular Automata) can easily enter infinite states if constraints are impossible. Always include a `max_iterations` safety break.
- **NEVER instantiate nodes directly from proc-gen threads** — You cannot touch the SceneTree from a worker thread. Generate the *data* in the thread, then notify the Main Thread to handle `add_child()`.
- **NEVER use complex WFC for simple layouts** — Wave Function Collapse is powerful but overkill for simple paths. Use **Drunkard's Walk** or **BSP** for lightweight structured layouts.
- **NEVER rely on `TileMap.set_cell()` for large-scale updates** — Updating 10,000 cells individually is slow. Prepare a `TileMapPattern` and use `set_pattern()` or `set_cells_terrain_connect()` for batch updates.
- **NEVER forget to bake Navigation at the end** — Procedurally generated worlds need their navmeshes rebaked at runtime or the AI will walk into walls.
- **NEVER ignore data serialization** — If you generate a world, you must be able to save the *seed* and any *player modifications*. Don't try to save the entire raw chunk state if avoidable.

---

```gdscript
func generate_dungeon(width: int, height: int, fill_percent: float = 0.4) -> Array:
    var grid := []
    for y in height:
        var row := []
        for x in width:
            row.append(1)  # 1 = wall
        grid.append(row)
    
    # Start in center
    var x := width / 2
    var y := height / 2
    var floor_tiles := 0
    var target_floor := int(width * height * fill_percent)
    
    while floor_tiles < target_floor:
        if grid[y][x] == 1:
            grid[y][x] = 0  # Create floor
            floor_tiles += 1
        
        # Random walk
        var dir := randi() % 4
        match dir:
            0: x = clampi(x + 1, 0, width - 1)
            1: x = clampi(x - 1, 0, width - 1)
            2: y = clampi(y + 1, 0, height - 1)
            3: y = clampi(y - 1, 0, height - 1)
    
    return grid
```

## Perlin Noise Terrain

```gdscript
var noise := FastNoiseLite.new()

func generate_terrain(width: int, height: int) -> Array:
    noise.seed = randi()
    noise.frequency = 0.05
    
    var terrain := []
    for y in height:
        var row := []
        for x in width:
            var value := noise.get_noise_2d(x, y)
            
            # Map noise to tile types
            var tile: int
            if value < -0.2:
                tile = 0  # Water
            elif value < 0.2:
                tile = 1  # Grass
            else:
                tile = 2  # Mountain
            
            row.append(tile)
        terrain.append(row)
    
    return terrain
```

## BSP Rooms

```gdscript
class_name BSPRoom

var x: int
var y: int
var width: int
var height: int
var left: BSPRoom = null
var right: BSPRoom = null

func split(min_size: int = 6) -> bool:
    if left or right:
        return false  # Already split
    
    # Choose split direction
    var split_horizontal := randf() > 0.5
    
    if width > height and float(width) / float(height) >= 1.25:
        split_horizontal = false
    elif height > width and float(height) / float(width) >= 1.25:
        split_horizontal = true
    
    var max := (height if split_horizontal else width) - min_size
    if max <= min_size:
        return false  # Too small
    
    var split_pos := randi_range(min_size, max)
    
    if split_horizontal:
        left = BSPRoom.new()
        left.x = x
        left.y = y
        left.width = width
        left.height = split_pos
        
        right = BSPRoom.new()
        right.x = x
        right.y = y + split_pos
        right.width = width
        right.height = height - split_pos
    else:
        left = BSPRoom.new()
        left.x = x
        left.y = y
        left.width = split_pos
        left.height = height
        
        right = BSPRoom.new()
        right.x = x + split_pos
        right.y = y
        right.width = width - split_pos
        right.height = height
    
    return true

func generate_bsp_dungeon(width: int, height: int, iterations: int = 4) -> Array[BSPRoom]:
    var root := BSPRoom.new()
    root.x = 0
    root.y = 0
    root.width = width
    root.height = height
    
    var rooms: Array[BSPRoom] = [root]
    
    for i in iterations:
        var new_rooms: Array[BSPRoom] = []
        for room in rooms:
            if room.split():
                new_rooms.append(room.left)
                new_rooms.append(room.right)
            else:
                new_rooms.append(room)
        rooms = new_rooms
    
    return rooms
```

## Random Loot

```gdscript
func generate_loot(loot_level: int) -> Array[Item]:
    var items: Array[Item] = []
    var roll_count := randi_range(1, 3)
    
    for i in roll_count:
        var rarity := roll_rarity()
        var item := get_random_item(rarity, loot_level)
        items.append(item)
    
    return items

func roll_rarity() -> String:
    var roll := randf()
    if roll < 0.6:
        return "common"
    elif roll < 0.85:
        return "uncommon"
    elif roll < 0.95:
        return "rare"
    else:
        return "legendary"
```

## Wave Function Collapse

```gdscript
# Simplified WFC for tile patterns
# Load compatible tile adjacency rules
var tile_rules := {
    "grass": ["grass", "path", "water_edge"],
    "water": ["water", "water_edge"],
    "path": ["grass", "path"]
}

func wfc_generate(width: int, height: int) -> Array:
    var grid := []
    for y in height:
        var row := []
        for x in width:
            row.append(null)  # Uncollapsed
        grid.append(row)
    
    # Collapse cells until complete
    while has_uncollapsed(grid):
        var pos := find_lowest_entropy(grid)
        collapse_cell(grid, pos)
        propagate_constraints(grid, pos)
    
    return grid
```

## Best Practices

1. **Seeding** - Use seeds for reproducibility
2. **Validation** - Ensure playable levels
3. **Performance** - Generate async if needed

## Reference
- Related: `godot-tilemap-mastery`, `godot-resource-data-patterns`


### Related
- Master Skill: [godot-master](../SKILL.md)
