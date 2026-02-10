---
name: godot-3d-world-building
description: "Expert patterns for 3D level design using GridMap with MeshLibrary, CSG constructive solid geometry, WorldEnvironment setup, ProceduralSkyMaterial, and volumetric fog. Use when building 3D levels, modular tilesets, BSP-style geometry, or environmental effects. Trigger keywords: GridMap, MeshLibrary, set_cell_item, get_cell_item, map_to_local, local_to_map, CSGCombiner3D, CSGBox3D, CSGSphere3D, CSGPolygon3D, WorldEnvironment, Environment, Sky, ProceduralSkyMaterial, PanoramaSkyMaterial, fog_enabled, volumetric_fog_enabled."
---

# 3D World Building

Expert guidance for level design with GridMaps, CSG, and environmental setup.

## NEVER Do

- **NEVER forget to bake GridMap navigation** — GridMaps don't auto-generate navigation meshes. Use EditorPlugin or manual NavigationRegion3D.
- **NEVER use CSG for final game geometry** — CSG is for prototyping. Convert to static meshes for performance (use "Bake CSG Mesh" in editor).
- **NEVER scale GridMap cell size after placing tiles** — Changing `cell_size` doesn't update existing tiles, causing misalignment. Set it once at the start.
- **NEVER use MeshLibrary without collision shapes** — Items without collision spawn visual-only geometry that players fall through.
- **NEVER enable volumetric fog without DirectionalLight3D** — Volumetric fog requires at least one light to scatter. No lights = no visible fog.

---

## Available Scripts

> **MANDATORY**: Read the appropriate script before implementing the corresponding pattern.

### [collision_gen.gd](scripts/collision_gen.gd)
Automatic collision shape generation from meshes. Use when importing models without collision or for procedural geometry.

### [gridmap_runtime_builder.gd](scripts/gridmap_runtime_builder.gd)
Runtime GridMap tile placement with batch operations and auto-navigation baking.

### [csg_bake_tool.gd](scripts/csg_bake_tool.gd)
EditorScript to bake CSG geometry to static meshes with proper materials and collision. Use when finalizing level prototypes.

### [lod_manager.gd](scripts/lod_manager.gd)
Level-of-detail switching based on camera distance. Manages mesh swapping and visibility for large outdoor scenes.

### [occlusion_setup.gd](scripts/occlusion_setup.gd)
OccluderInstance3D configuration for manual occlusion culling. Use for indoor levels with many rooms.

---

## GridMap Fundamentals

### Setup Workflow

```gdscript
# 1. Create MeshLibrary resource (editor)
# Scene → New Inherits Scene → Create Grid-aligned meshes
# Scene → Convert To → MeshLibrary...

# 2. Assign to GridMap
extends GridMap

func _ready() -> void:
    mesh_library = load("res://tilesets/dungeon_library.tres")
    cell_size = Vector3(2, 2, 2)  # Must match library cell size
```

### Cell Manipulation

```gdscript
# gridmap_builder.gd
extends GridMap

# Place cell
func place_tile(grid_pos: Vector3i, tile_index: int) -> void:
    set_cell_item(grid_pos, tile_index)

# Get cell
func get_tile(grid_pos: Vector3i) -> int:
    return get_cell_item(grid_pos)  # Returns index or INVALID_CELL_ITEM (-1)

# Remove cell
func remove_tile(grid_pos: Vector3i) -> void:
    set_cell_item(grid_pos, INVALID_CELL_ITEM)

# Rotate cell (0-23, see GridMap.ROTATION_* constants)
func place_rotated(grid_pos: Vector3i, tile_index: int, orientation: int) -> void:
    set_cell_item(grid_pos, tile_index, orientation)
```

### Coordinate Conversion

```gdscript
# World position ↔ Grid coordinates
func _input(event: InputEvent) -> void:
    if event is InputEventMouseButton and event.pressed:
        var camera := get_viewport().get_camera_3d()
        var from := camera.project_ray_origin(event.position)
        var to := from + camera.project_ray_normal(event.position) * 1000
        
        var space := get_world_3d().direct_space_state
        var query := PhysicsRayQueryParameters3D.create(from, to)
        var result := space.intersect_ray(query)
        
        if result:
            var world_pos: Vector3 = result.position
            var grid_pos := local_to_map(to_local(world_pos))
            place_tile(grid_pos, 0)  # Place tile at clicked position

# Grid → World
func get_cell_center(grid_pos: Vector3i) -> Vector3:
    return to_global(map_to_local(grid_pos))
```

---

## MeshLibrary Creation

### Collision Setup

```gdscript
# tile_scene.tscn (before converting to MeshLibrary)
# Root: Node3D
#   ├─ MeshInstance3D (visual)
#   └─ StaticBody3D (collision)
#       └─ CollisionShape3D

# CRITICAL: StaticBody3D must be sibling/child for GridMap to detect collision
```

### Item Metadata

```gdscript
# Access MeshLibrary item data
func get_tile_name(tile_index: int) -> String:
    return mesh_library.get_item_name(tile_index)

# Custom metadata (stored in MeshLibrary resource)
# Use item_set_name() in editor script to organize
```

---

## CSG (Constructive Solid Geometry)

### Boolean Operations

```
CSG Combiner3D
  ├─ CSGBox3D (Operation: Union)        # Base room
  ├─ CSGBox3D (Operation: Subtraction)  # Door cutout
  └─ CSGSphere3D (Operation: Intersection)  # Rounded corner
```

### CSG Brush Types

```gdscript
# CSGBox3D - Room primitives
var room := CSGBox3D.new()
room.size = Vector3(10, 5, 10)

# CSGCylinder3D - Pillars
var pillar := CSGCylinder3D.new()
pillar.radius = 0.5
pillar.height = 5.0

# CSGSphere3D - Domes
var dome := CSGSphere3D.new()
dome.radius = 3.0
dome.radial_segments = 16
dome.rings = 8

# CSGPolygon3D - Extruded 2D shapes
var arch := CSGPolygon3D.new()
arch.polygon = PackedVector2Array([
    Vector2(-1, 0), Vector2(-1, 2), Vector2(1, 2), Vector2(1, 0)
])
arch.depth = 0.5
```

### CSG Performance

```gdscript
# ❌ BAD: Use CSG at runtime (slow)
func _ready() -> void:
    var csg := CSGBox3D.new()
    add_child(csg)  # Recalculates mesh every frame

# ✅ GOOD: Bake to MeshInstance3D (editor only)
# Select CSG node → Mesh → Bake Mesh Instance
# Then delete CSG node

# ✅ ALSO GOOD: Use CSG for level editor, bake on export
```

---

## WorldEnvironment Setup

### Sky Configuration

```gdscript
# world_env.gd
extends WorldEnvironment

func _ready() -> void:
    var env := Environment.new()
    environment = env
    
    # Procedural sky
    env.background_mode = Environment.BG_SKY
    var sky := Sky.new()
    var sky_mat := ProceduralSkyMaterial.new()
    
    sky_mat.sky_top_color = Color(0.4, 0.6, 1.0)  # Blue
    sky_mat.sky_horizon_color = Color(0.8, 0.9, 1.0)  # Lighter
    sky_mat.ground_bottom_color = Color(0.2, 0.2, 0.1)
    sky_mat.sun_angle_max = 30.0
    
    sky.sky_material = sky_mat
    env.sky = sky
```

### HDRI Skybox

```gdscript
# For realistic lighting
var env := environment
env.background_mode = Environment.BG_SKY

var sky := Sky.new()
var panorama := PanoramaSkyMaterial.new()
panorama.panorama = load("res://hdri/sunset.hdr")  # Equirectangular HDR image

sky.sky_material = panorama
env.sky = sky

# Sky contribution to ambient light
env.ambient_light_source = Environment.AMBIENT_SOURCE_SKY
env.ambient_light_sky_contribution = 1.0
```

---

## Fog & Atmosphere

### Exponential Fog

```gdscript
extends WorldEnvironment

func _ready() -> void:
    var env := environment
    
    env.fog_enabled = true
    env.fog_mode = Environment.FOG_MODE_EXPONENTIAL
    env.fog_density = 0.01  # 0.0-1.0
    env.fog_light_color = Color(0.9, 0.95, 1.0)  # Blueish
    env.fog_light_energy = 1.0
```

### Depth Fog

```gdscript
# Distance-based fog
env.fog_enabled = true
env.fog_mode = Environment.FOG_MODE_DEPTH
env.fog_depth_begin = 50.0  # Start distance
env.fog_depth_end = 200.0   # End distance (fully opaque)
env.fog_depth_curve = 1.0   # Falloff curve
```

### Volumetric Fog

```gdscript
# Requires DirectionalLight3D for scattering
env.volumetric_fog_enabled = true
env.volumetric_fog_density = 0.05
env.volumetric_fog_albedo = Color(0.9, 0.9, 1.0)
env.volumetric_fog_emission = Color.BLACK
env.volumetric_fog_gi_inject = 1.0  # How much GI affects fog

# Performance settings
env.volumetric_fog_temporal_reprojection_enabled = true
env.volumetric_fog_detail_spread = 2.0
```

---

## Level Streaming / LOD

### GridMap Chunking

```gdscript
# level_streamer.gd - Load/unload GridMap chunks based on player position
extends Node3D

@export var chunk_size := 32  # Grid cells per chunk
@export var load_radius := 2  # Chunks to keep loaded

var loaded_chunks := {}  # Vector2i → GridMap

func _process(delta: float) -> void:
    var player_pos := get_player_position()
    var player_chunk := Vector2i(
        int(player_pos.x / (chunk_size * cell_size.x)),
        int(player_pos.z / (chunk_size * cell_size.z))
    )
    
    # Load nearby chunks
    for x in range(-load_radius, load_radius + 1):
        for z in range(-load_radius, load_radius + 1):
            var chunk_coord := player_chunk + Vector2i(x, z)
            if chunk_coord not in loaded_chunks:
                load_chunk(chunk_coord)
    
    # Unload distant chunks
    for chunk_coord in loaded_chunks.keys():
        var dist := chunk_coord.distance_to(player_chunk)
        if dist > load_radius:
            unload_chunk(chunk_coord)

func load_chunk(coord: Vector2i) -> void:
    var gridmap := GridMap.new()
    gridmap.mesh_library = preload("res://library.tres")
    add_child(gridmap)
    loaded_chunks[coord] = gridmap
    
    # TODO: Load chunk data from file/database
    # gridmap.set_cell_item(...)

func unload_chunk(coord: Vector2i) -> void:
    var gridmap: GridMap = loaded_chunks[coord]
    gridmap.queue_free()
    loaded_chunks.erase(coord)
```

---

## Procedural Generation

### Random Dungeon with GridMap

```gdscript
# dungeon_generator.gd
extends GridMap

enum Tile { FLOOR, WALL, DOOR }

func generate_room(pos: Vector3i, size: Vector3i) -> void:
    # Fill with floor
    for x in range(size.x):
        for z in range(size.z):
            set_cell_item(pos + Vector3i(x, 0, z), Tile.FLOOR)
    
    # Add walls
    for x in range(size.x):
        set_cell_item(pos + Vector3i(x, 0, 0), Tile.WALL)  # North
        set_cell_item(pos + Vector3i(x, 0, size.z - 1), Tile.WALL)  # South
    
    for z in range(size.z):
        set_cell_item(pos + Vector3i(0, 0, z), Tile.WALL)  # West
        set_cell_item(pos + Vector3i(size.x - 1, 0, z), Tile.WALL)  # East

func _ready() -> void:
    generate_room(Vector3i(0, 0, 0), Vector3i(10, 1, 10))
```

---

## Edge Cases

### GridMap Cells Not Colliding

```gdscript
# Problem: MeshLibrary items lack collision
# Solution: Ensure StaticBody3D + CollisionShape3D in source scene

# Verify in code:
var item_shapes := mesh_library.get_item_shapes(tile_index)
if item_shapes.is_empty():
    push_error("Tile %d has no collision!" % tile_index)
```

### CSG Mesh Flickering

```gdscript
# Problem: Z-fighting between overlapping CSG operations
# Solution: Add small offset (0.001) to prevent exact overlap

var box := CSGBox3D.new()
box.size = Vector3(10, 5, 10)

var cutout := CSGBox3D.new()
cutout.operation = CSGShape3D.OPERATION_SUBTRACTION
cutout.size = Vector3(2, 3, 2.002)  # Slightly larger depth
```


## Reference
- Master Skill: [godot-master](../godot-master/SKILL.md)
